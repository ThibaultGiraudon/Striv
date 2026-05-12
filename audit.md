# Rapport d'audit — Striv

**Projet** : Striv — application iOS de suivi de course à pied
**Date de l'audit** : 11 mai 2026
**Auditeur** : Claude (Opus 4.7)
**Périmètre** : code source complet (app iOS + extension widget + tests unitaires + configuration projet)

---

## 1. Vue d'ensemble

### 1.1 Description du projet

Striv est une application iOS native écrite en **SwiftUI** dont l'objectif est de proposer aux coureurs un outil d'analyse fine de leurs séances et de leur progression. Elle se positionne comme un complément intelligent à Apple Santé / Apple Fitness, en exploitant les données HealthKit déjà collectées par l'iPhone ou l'Apple Watch et en y ajoutant :

- des agrégats hebdomadaires/mensuels et un suivi de série (streak) ;
- la détection automatique de records personnels (PR) sur les distances étalons (5 km, 10 km, semi-marathon, marathon) ;
- un module de définition d'objectif de course (allure cible, projection vs. PR) ;
- une analyse textuelle de chaque séance générée par un **LLM (Gemini 2.5 Flash Lite via FirebaseAI)** ;
- un suivi de la prochaine course (compte à rebours) ;
- une suite de widgets (objectif hebdo, dernière course, PRs, streak) partageant les données via App Group.

### 1.2 Public cible

Coureurs réguliers (intermédiaire à avancé) francophones équipés d'un iPhone et possiblement d'une Apple Watch, qui :

- pratiquent la course en autonomie et veulent visualiser leur volume hebdo et leur progression mensuelle ;
- visent un objectif de course (semi, marathon, etc.) et veulent connaître la faisabilité par rapport à leur PR ;
- apprécient l'analyse qualitative et la rétroaction automatisée plutôt que la pure collecte de données ;
- utilisent les widgets iOS comme tableau de bord rapide.

### 1.3 Stack technique observée

| Couche | Technologie |
|---|---|
| UI | SwiftUI, Swift Charts, MapKit, WidgetKit |
| Architecture | MVVM + protocoles (HealthKitHelperInterface, ReachabilityUC) |
| Persistance locale | SwiftData (`@Model`) avec App Group container |
| Données santé | HealthKit (workouts, routes GPS, samples) |
| IA | FirebaseAI (Gemini 2.5 Flash Lite) |
| Réseau | `Network.framework` (NWPathMonitor) |
| Concurrence | `async/await`, `actor`, `Task` |
| Tests | XCTest + fakes (HealthKitFake) + in-memory `ModelContainer` |
| Cible OS | iOS 26 (utilisation de `Tab`, `.glassEffect`, `ToolbarSpacer`, SF Symbol `apple.intelligence`) |

### 1.4 Statut du projet

Le README l'annonce explicitement : **work in progress**. L'audit confirme un projet en phase de consolidation : structure mature, fonctionnalités principales implémentées, mais quelques zones inachevées (challenges désactivés, TODO résiduels, doublons widget/app).

---

## 2. Points forts

### 2.1 Architecture et séparation des couches

- **MVVM appliqué correctement dans l'ensemble** : Views ne contiennent pas de logique métier, ViewModels exposent un état observable, services et repositories isolés des Views.
- **Couche Repository derrière un protocole** (`HealthKitHelperInterface`) : permet l'injection de fakes pour les tests — c'est un excellent réflexe rarement présent à ce stade d'un projet.
- **Repositories HealthKit splittés en extensions thématiques** (`+anchor`, `+fetchQuantity`, `+metrics`, `+routes`, `+workouts`) : très lisible, modulaire, facile à maintenir.
- **Erreurs métier modélisées en enums localisés** (`AIError`, `HealthKitError`, `AppError`, `DatabaseError`, `ValidationError`) avec `title`/`description`/`icon` — idiomatique et exploitable directement par la couche UI (`ContentUnavailableView`).
- **`BaseViewModel` + `ErrorPresenter`** : centralisation propre de la présentation d'erreurs, évite les `@State` d'erreur disséminés.

### 2.2 Concurrence

- **Usage généralisé d'`async/await`** : pas de callback hell, pas de `DispatchQueue.main.async` éparpillés.
- **`HealthKitHelper` est un `actor`** : choix correct car `HKHealthStore` n'est pas garanti thread-safe et beaucoup d'apps tombent dans ce piège.
- **Parallélisme intelligent dans `fetchWorkoutDetail`** : `async let hr / kcal / power / stepCount` lancés en parallèle puis attendus, ce qui réduit la latence perçue d'un facteur ~4.
- **Traitement des PR en arrière-plan** (`Task(priority: .background)`) avec batches dimensionnés sur `activeProcessorCount` et yield (`Task.sleep`) : bon équilibre throughput / responsivité.

### 2.3 Performance

- **Sync HealthKit incrémentale via `HKAnchoredObjectQuery`** : seuls les nouveaux workouts sont importés à chaque appel, l'ancre étant persistée dans `UserDefaults`. Indispensable pour un utilisateur avec un historique long.
- **Downsampling des altitudes** (`Array+Downsample.swift`, plafond 300 points) : protège SwiftUI Charts d'un crash sur des courses longues (≥1000 points GPS).
- **Algorithme deux-pointeurs dans `bestTimes(in:)`** : complexité amortie linéaire pour calculer les PR sur toutes les distances étalons à partir d'un seul parcours de samples.

### 2.4 Intégrations système

- **App Group `group.striv`** correctement configuré sur l'app principale et l'extension widget, avec un `ModelContainer` SwiftData placé dans le conteneur partagé : architecture propre pour l'avenir si le widget doit lire SwiftData directement.
- **Pont app ↔ widget par `UserDefaults(suiteName:)` + `WidgetCenter.reloadAllTimelines()`** : choix simple et fiable pour transmettre un snapshot.
- **`WidgetBundle` avec 4 widgets distincts** (Distance, Streak, PRs, LastRun) bien découpés.
- **Police personnalisée Switzer** chargée via `UIAppFonts` côté app *et* côté widget — détail souvent oublié.

### 2.5 Qualité IA

- **Prompt Gemini extrêmement cadré** : instructions explicites, format JSON strict imposé, contraintes de longueur (180 mots), garde-fous contre les jugements négatifs, gestion des données absentes. Ce niveau de prompt engineering est rare dans une app indé.
- **Validation post-parsing** : décodage défensif via `JSONSerialization` avec sortie typée (`Analyze`), pas de confiance aveugle dans la réponse du modèle.
- **Reachability check avant appel** : évite un timeout long et coûteux quand le réseau est absent.
- **Cache de l'analyse dans le workout** (`analyzeRaw`) : pas de re-génération inutile, économie de coût Firebase.
- **Écran d'information dédié à l'IA** (`AIInfoView`) qui explique les limites et le bon usage — bonne pratique d'UX honnête.

### 2.6 Tests

- **Présence de tests unitaires** avec **double pattern propre** : fake conforme à `HealthKitHelperInterface` + container SwiftData en mémoire pour isoler les tests.
- **Couverture des cas critiques** : agrégats globaux, streak (current + longest), import workout, gestion d'erreur, détection PR sur 5 et 10 km.

### 2.7 Documentation interne

- **Docstrings Swift (DocC-friendly)** très bien rédigées sur les modèles, services et repositories. C'est précieux pour la maintenance et la reprise par un tiers.

---

## 3. Points faibles, bugs et risques

Les éléments sont classés par criticité.

### 3.1 Critique — bloquant en production

#### 3.1.1 `NSHealthShareUsageDescription` absent du `Info.plist`

Le `Info.plist` de la cible Striv ne contient **que** la déclaration `UIAppFonts`. Or l'appel à `healthStore.requestAuthorization(...)` exige obligatoirement la clé `NSHealthShareUsageDescription` (et idéalement `NSHealthUpdateUsageDescription`). Sans elle :

- en debug : Xcode lèvera un crash immédiat sur la demande d'autorisation ;
- en review App Store : rejet automatique.

**Action** : ajouter dans `Striv/Info.plist` :

```xml
<key>NSHealthShareUsageDescription</key>
<string>Striv lit vos courses Apple Santé pour analyser votre progression.</string>
```

Si la clé est déjà présente dans le build settings du projet (`INFOPLIST_KEY_NSHealthShareUsageDescription`), à vérifier ; sinon à ajouter d'urgence.

#### 3.1.2 Bug de précision sur le calcul de l'allure

Dans `Workout.swift:68` :

```swift
@Transient var pace: Pace {
    Pace(pace: Double(duration.totalSeconds / 60) / ((distance ?? 1) / 1000))
}
```

`duration.totalSeconds / 60` est une **division entière** (les deux opérandes sont `Int`), donc 3672 s → 61 min au lieu de 61,2 min. Le `Double(...)` n'est appliqué qu'**après** la troncature. Conséquence : l'allure affichée perd la part de seconde et peut différer de quelques secondes/km vs. ce qu'affiche l'app Apple Fitness.

**Correctif** :

```swift
Pace(pace: (Double(duration.totalSeconds) / 60.0) / ((distance ?? 1) / 1000))
```

#### 3.1.3 Double-optionnel sur l'altitude HealthKit

Dans `HealthKit+workouts.swift:101` :

```swift
elevation: (hkWorkout.metadata?["HKElevationAscended"] as? HKQuantity?)??.doubleValue(for: .meter()),
```

Le cast `as? HKQuantity?` produit un `HKQuantity??` (double-optionnel) ce qui force le `??.` douteux. La métadonnée renvoie un `HKQuantity` simple. Correct :

```swift
elevation: (hkWorkout.metadata?["HKElevationAscended"] as? HKQuantity)?.doubleValue(for: .meter()),
```

Le code actuel compile mais peut renvoyer `nil` même quand la donnée existe selon le compilateur.

#### 3.1.4 `AppError.id` génère un UUID neuf à chaque accès

Dans `BaseViewModel.swift:55` :

```swift
var id: UUID { UUID() }
```

`Identifiable` exige une identité **stable**. SwiftUI utilise `id` pour décider si l'`.alert(item:)` doit ré-afficher : ici chaque rendu produit un nouvel ID, donc l'alerte peut être réinstanciée en boucle ou disparaître. Définir un ID stable (par cas, ou stocker l'UUID dans le `case`).

#### 3.1.5 Règles de suppression SwiftData non définies

Les relations `Workout.coordinates`, `Workout.samples` n'ont pas de `deleteRule` explicite. Le défaut est `.nullify`, donc lors de la suppression d'un workout (notamment quand HealthKit signale une suppression côté Apple Santé), les `Coordinate` et `RunSampleEntity` restent orphelins en base. À grande échelle : fuite de stockage.

**Correctif** :

```swift
@Relationship(deleteRule: .cascade) var coordinates: [Coordinate]
@Relationship(deleteRule: .cascade) var samples: [RunSampleEntity] = []
```

### 3.2 Élevé

#### 3.2.1 Doublons de code app ↔ widget

Quatre éléments sont **redéclarés** dans l'extension widget alors qu'ils existent déjà dans l'app principale :

| Élément | App | Widget |
|---|---|---|
| `WidgetData` | `Striv/Models/WidgetData.swift` | `StrivWidget/StrivWidget.swift` |
| `PR` | idem | idem |
| `extension Date.formatted(format:)` | `Striv/Extensions/Date+formatted.swift` | `StrivWidget/LastRunWidget.swift` |
| Police Switzer | `Font+.swift` | implicite via `UIAppFonts` |

Risque : divergence silencieuse entre les deux définitions (déjà visible — `PR` est `Codable, Hashable` côté widget mais seulement `Codable` côté app). Solution recommandée : créer un **Swift Package local** (ex : `StrivShared`) embarquant ces types, le faire pointer par les deux cibles.

#### 3.2.2 Concurrence `ObservableObject` non annotée

`WorkoutsViewModel`, `DashboardViewModel`, `ChallengeViewModel`, `NextRaceViewModel`, `WidgetDataViewModel`, `TargetViewModel`, `RunnerProfileViewModel` modifient des `@Published` sans être annotés `@MainActor` (sauf `BaseViewModel`). En **Swift 6 strict concurrency**, cela provoquera des erreurs ; en Swift 5 actuel, ce sont des warnings et des risques de race conditions.

**Action** : marquer chaque `ObservableObject` `@MainActor` (ou migrer vers `@Observable` du macro Observation iOS 17+).

#### 3.2.3 SwiftData : pas de stratégie de versioning

`ModelContainer` est initialisé sans `Schema`/`VersionedSchema`. À la première mise à jour du modèle de données (ajout d'un champ à `Workout`, par ex.), l'app crashera ou perdra la base si la migration n'est pas définie. Le `fatalError("SwiftData init failed: \(error)")` dans `StrivApp.swift:59` aggrave la situation : un utilisateur passant à une nouvelle version sera coincé.

**Action** : introduire `VersionedSchema` + `SchemaMigrationPlan` dès maintenant, avant la sortie publique.

#### 3.2.4 `weeklyStats` génère toutes les semaines depuis la première course

`WorkoutStatisticsService.weeklyStats` itère de la première course à aujourd'hui en ajoutant chaque semaine (vide ou non). Pour un utilisateur ayant commencé il y a 5 ans, c'est ~260 entrées recalculées **à chaque modification de `workouts`** via `@Query` qui ré-émet sur la moindre insertion. Acceptable aujourd'hui, mais à surveiller. La même remarque vaut pour `monthlyStats`.

Pistes : limiter à N dernières semaines pour l'affichage, ou mettre en cache et invalider sur changement de cardinalité.

#### 3.2.5 Streak calculé sur des semaines complètes

`currentStreak` parcourt les semaines triées de la plus récente à la plus ancienne et s'arrête à la première semaine vide. Or `weeklyStats` ajoute toujours la semaine courante, qui peut être vide si on est lundi matin et que l'utilisateur n'a pas encore couru cette semaine. Résultat : un utilisateur qui a couru 10 semaines consécutives se réveille un lundi avec une streak affichée à **0**.

**Correctif** : ignorer la semaine en cours si elle est vide ET ne pas être encore terminée, ou exclure les semaines incomplètes.

#### 3.2.6 Données IA envoyées à un tiers sans politique de confidentialité

`AIService.analyze` envoie à Gemini (Google) : date, durée, distance, fréquence cardiaque, calories, dénivelé, cadence, puissance, objectif du coureur. Il s'agit de **données de santé** au sens du RGPD. Le projet doit :

- afficher un **consentement explicite** à la première utilisation de l'analyse ;
- documenter un lien vers une **politique de confidentialité** (obligatoire pour soumission App Store) ;
- préciser dans `AIInfoView` que les données sont transmises à Google ;
- considérer une option « analyse locale » (CoreML) ou un mode hors-ligne.

#### 3.2.7 Aucune gestion de retry / timeout côté IA

`AIRepository.askGemini` n'a pas de timeout configuré et aucune logique de retry sur erreur transitoire (5xx). Sur un réseau dégradé l'appel peut bloquer ~60 s.

#### 3.2.8 Logs de debug oubliés

- `WorkoutStatisticsService.swift:178` → `print(firstMonth)`
- `WorkoutsViewModel.swift:104` → `print(error.localizedDescription)`
- Plusieurs `print` dans `StrivWidget.swift` (`loadData()`)

À retirer ou remplacer par `os.Logger`.

### 3.3 Moyen

#### 3.3.1 Nommage / organisation

- Les fichiers `AIService.swift` et `WorkoutStatisticsService.swift` se trouvent dans le dossier `ViewModels/` alors qu'il s'agit de **services métier** (et `AIService` ne conforme même pas à `ObservableObject`). À déplacer dans `Services/`.
- `AnalyzeViewModel` (classe) vs `AnalyseView` (vue) : orthographe incohérente (`Analyze` / `Analyse`).
- `ReachabilityUC` : suffixe `UC` (UseCase ?) inhabituel et non documenté.
- Types côté UI redéclarés portant le **même nom** que des types du modèle : `struct StreakView` existe dans l'app *et* dans le widget, idem `struct PRsView`. À renommer (`PRsWidgetView` / `StreakWidgetView`) pour éviter la confusion.

#### 3.3.2 `Duration` modélisé comme `@Model` SwiftData

`Duration` est marqué `@Model final class`. Pourtant il ne contient que 4 entiers, est lié 1-1 à un workout, et n'est jamais référencé indépendamment. Le coût SwiftData (table, jointure) est disproportionné. Une `struct Codable` stockée dans un attribut binaire (ou simplement un `Int totalSeconds`) suffirait. Idem la sémantique `Hashable` actuelle ne tient pas la promesse `==` ↔ `hash` (OK ici) mais le stockage en table relationnelle est superflu.

#### 3.3.3 `RunnerProfile.prs` encodé en JSON dans un blob

Le dictionnaire `[PresetDistance: PRResult]` est sérialisé en JSON dans `prsData` puis re-décodé à chaque accès. Trois inconvénients :

- accès O(parse) à chaque lecture du transient ;
- impossibilité de requêter SwiftData sur un PR particulier ;
- pas de migration automatique si `PRResult` change de forme.

Préférer une entité `@Model PR` reliée par `@Relationship` à `RunnerProfile`.

#### 3.3.4 Recalculs SwiftUI répétés

- `Workout.coordinates2d` re-trie l'array à **chaque accès** (utilisé dans `RouteMapView` rendu plusieurs fois par frame en cas d'animation).
- `Workout.analyze` re-parse le JSON à chaque accès.
- `RunnerProfile.prs` re-décode à chaque accès.

Ces propriétés `@Transient` devraient être mémoïsées dans un cache `@Transient private var` paresseux.

#### 3.3.5 `RunsListView` et `ContentView` dupliquent la construction de `WidgetData`

~10 lignes identiques dans les deux fichiers. À extraire dans une méthode `WidgetDataBuilder.build(from:targetVM:profile:)`.

#### 3.3.6 `ChallengesView` mort

L'onglet Challenges est commenté dans `ContentView`. Le `ChallengeViewModel` est implémenté, la vue aussi, mais incomplète (cases `.duration` retournent toujours 0, et le code-mort introduit de la dette).

Soit terminer la feature, soit retirer temporairement le code.

#### 3.3.7 Mélange français / anglais

Strings UI mélangées :

| Endroit | Langue |
|---|---|
| Onglets, titres principaux | français |
| `RunDetailView` : "Morning run", "Heart rate", "Show Stats" | anglais |
| `RunsListView` : "All runs", "Download" | anglais |
| Prompt IA | français |
| Erreurs `AIError` (`"No internet connection."`) | anglais |
| Erreurs `AppError` (`"Une erreur..."`) | français |

À uniformiser via **String Catalog (`.xcstrings`, iOS 17+)** dès aujourd'hui : c'est trivial à migrer maintenant, douloureux plus tard.

#### 3.3.8 Pas d'accessibilité explicite

Aucun `accessibilityLabel`, `accessibilityHint`, `accessibilityElement` détecté. Les valeurs numériques (`Text("\(distance, specifier: "%.2f") km")`) seront lues caractère par caractère par VoiceOver. Les graphiques Swift Charts n'ont pas de description alternative. À traiter en priorité moyenne.

#### 3.3.9 Markdown littéral affiché dans l'analyse IA

Dans le `#Preview` de `AnalyzeView`, les items contiennent `**Endurance de base**:` — le double-astérisque s'affichera tel quel car les items sont rendus en `Text(item)` sans `try AttributedString(markdown:)`. À mitiger côté prompt (interdire le markdown) **ou** côté rendu (`Text(try? AttributedString(markdown: item) ?? item)`).

#### 3.3.10 Cible iOS 26 uniquement

Le code utilise `.glassEffect()`, le nouveau `Tab` SwiftUI (Liquid Glass), `ToolbarSpacer`, le SF Symbol `apple.intelligence` — tous **iOS 26**. C'est un choix légitime mais il faut en avoir conscience :

- la base d'utilisateurs potentielle est restreinte aux iPhones très récents ;
- le `Deployment Target` doit être verrouillé à iOS 26 sinon le code ne compile pas pour les anciennes versions ;
- aucun fallback `@available` n'est présent.

À documenter dans le README.

### 3.4 Faible

- `getWorkout` lève `NSError()` brut quand le workout est introuvable — créer un cas dédié dans `HealthKitError`.
- `NextRaceViewModel.setTitle("")` au lieu de `removeObject(forKey:)` quand on supprime.
- `DefineGoalViewModel.timeBounds` : formules `150 + km` magiques, pas de tests.
- `SegmentedPicker` recrée `@Namespace` à chaque rendu — fonctionne mais l'animation `matchedGeometryEffect` peut être moins fluide ; déplacer en `@State`.
- `ContentView` reconstruit `WidgetDataViewModel` à `init`, et `RunsListView` également ; deux instances pour la même responsabilité.
- `Workout.altitudes: [Double]` peut peser quelques Mo en base pour de très longues sorties : un blob `Data` compressé serait plus économe.
- Tests : `test_monthlyStats_shouldCalculateDistanceChange` ne vérifie pas la valeur de `distanceChange` (juste son existence) — assertion faible.
- Pas de tests pour `AIService`, `ChallengeViewModel`, `RunnerProfileViewModel`, `DefineGoalViewModel`, ni pour les vues (snapshot testing absent).
- Pas de configuration **SwiftLint / SwiftFormat** détectée — utile pour homogénéiser l'indentation, l'ordre des imports, les espaces avant `{`.
- Pas de CI (GitHub Actions / Xcode Cloud) : aucune protection contre une régression au merge.
- Le `.gitignore` ignore correctement `GoogleService-Info.plist` mais ce fichier n'est pas documenté dans le README → un collaborateur ne pourra pas compiler.

---

## 4. Sécurité et confidentialité

| Sujet | État | Commentaire |
|---|---|---|
| Clé API Firebase | OK | `GoogleService-Info.plist` gitignoré |
| HealthKit usage description | **MANQUANT** | bloquant production |
| Politique de confidentialité | absente | obligatoire pour App Store (données santé) |
| Consentement IA | absent | les données utilisateur partent chez Google sans confirmation |
| App Transport Security | OK | pas d'exception ATS |
| Keychain | non utilisé | OK (rien de secret côté client) |
| App Group | configuré | `group.striv` sur les deux cibles |
| Stockage local | en clair | acceptable pour données santé peu sensibles, mais à documenter |
| Logs | print bruts | risquer de fuiter `error.localizedDescription` en prod, utiliser `os.Logger` avec niveau `private` |

---

## 5. Performance et passage à l'échelle

| Risque | Impact | Recommandation |
|---|---|---|
| `weeklyStats` / `monthlyStats` linéaires sur l'historique complet, recalculés à chaque insertion | UI laggy pour utilisateurs anciens | cache + invalidation par delta |
| Re-parsing `analyze` / `prs` à chaque accès | léger mais cumulatif | mémoïsation paresseuse |
| `coordinates` non downsamplé (seul `altitudes` l'est) | rendu carte lent, RAM élevée | downsampler `coordinates2d` à 1 point/2 s |
| Pas de `deleteRule: .cascade` | fuite de stockage progressive | à corriger |
| Création de `Task` non annulée si vue détruite | léger mais réel | `.task {}` SwiftUI ou conserver les handles |
| Migration SwiftData absente | crash sur mise à jour de schéma | `VersionedSchema` |

---

## 6. UX et fonctionnel

### 6.1 Points positifs UX

- Onboarding implicite simple : import de la première course via un bouton dédié quand la base est vide.
- Streak visuel avec libellés progressifs ("Premier pas" → "Légende vivante").
- Carte du parcours avec style "muted" et désactivation des POI : bon focus sur la trace.
- Compte à rebours "Prochaine course" : levier de motivation intelligent.
- Module de définition d'objectif avec feedback couleur immédiat sur la faisabilité vs. PR.

### 6.2 Manques UX

- **Pas de notifications locales** (rappel de course, recap hebdomadaire, alerte streak en danger).
- **Pas d'écran d'onboarding** expliquant HealthKit, l'IA, la confidentialité.
- **`TargetViewModel.numberTarget` (objectif de séances/semaine) défini mais sans UI** pour le modifier.
- **Pas de filtres** sur la liste des courses (par distance, par mois, par type).
- **Pas de partage** (export GPX, partage social).
- **Pas de zones de fréquence cardiaque** ni d'analyse par intervalle (splits km).
- **Aucune comparaison entre deux courses** alors que les données le permettent.
- Les widgets ne se rafraîchissent qu'à l'ouverture de l'app (pas de `BGAppRefreshTask` ni de timeline réelle dynamique).
- La feature "Challenges" est désactivée — incomplète.

---

## 7. Tests

| Élément | Couvert | Commentaire |
|---|---|---|
| `WorkoutStatisticsService` | partiel | global, weekly, streak ; manque cas limites (semaine vide en cours, monthlyStats avec trou) |
| `WorkoutsViewModel` | partiel | fetch + fetchDetail + bestTimes ; manque deletion, processBatch |
| `AIService` | **non** | aucun test |
| `ChallengeViewModel` | **non** | |
| `RunnerProfileViewModel` | **non** | |
| `DefineGoalViewModel` | **non** | formules `timeBounds` non vérifiées |
| Vues SwiftUI | **non** | pas de snapshot ni de tests UI |
| Widget | **non** | |

Couverture estimée : **~15 %**. Pour un projet à ce stade c'est correct, mais insuffisant avant une mise en production.

---

## 8. Roadmap recommandée

### 8.1 Avant toute soumission App Store (bloquant)

1. Ajouter `NSHealthShareUsageDescription` au `Info.plist`.
2. Rédiger et lier une politique de confidentialité (gabarit RGPD + section IA).
3. Ajouter un consentement explicite à l'envoi de données à Gemini.
4. Corriger le bug de précision sur l'allure (`Workout.pace`).
5. Corriger le double-optionnel sur l'altitude (`HealthKit+workouts.swift:101`).
6. Stabiliser `AppError.id`.
7. Définir `VersionedSchema` + `SchemaMigrationPlan` SwiftData.
8. Définir les `deleteRule: .cascade` sur les relations `Workout`.
9. Nettoyer les `print` debug.

### 8.2 Avant la première version publique

1. Annoter tous les `ObservableObject` `@MainActor` (ou migrer vers `@Observable`).
2. Factoriser `WidgetData` / `PR` / `Date+formatted` dans un Swift Package partagé.
3. Localisation FR/EN via String Catalog.
4. Corriger la logique de streak pour ignorer la semaine en cours si lundi.
5. Soit terminer Challenges, soit retirer le code mort.
6. Couvrir `AIService`, `ChallengeViewModel`, `DefineGoalViewModel.timeBounds` par des tests.
7. Mettre en place SwiftLint + GitHub Actions (build + tests).
8. Documenter dans le README : pré-requis Firebase, version iOS, configuration `GoogleService-Info.plist`.

### 8.3 Évolutions / différenciation

1. Splits par km / mile, zones de FC.
2. Notifications locales (rappel streak, race countdown, recap hebdo).
3. Mode hors-ligne pour l'IA (CoreML ou un modèle plus petit).
4. Comparaison de deux courses similaires.
5. Export GPX / partage.
6. iCloud sync (CloudKit + SwiftData).
7. Apple Watch companion app pour démarrer une course directement.
8. Plan d'entraînement personnalisé généré par l'IA à partir du PR + objectif.
9. Achievements / Challenges fonctionnels.

---

## 9. Synthèse

**Striv est un projet solide pour un work-in-progress.** L'architecture MVVM est appliquée proprement, la couche HealthKit est exemplaire (actor + protocole + extensions thématiques), le prompt IA est très soigné, et la présence d'une suite de widgets WidgetKit + d'une suite de tests avec fakes témoigne d'une rigueur peu commune à ce stade.

Les faiblesses se concentrent sur **trois axes** :

1. **Production-readiness** : le `Info.plist` HealthKit manquant, l'absence de politique de confidentialité, le bug de pace et l'absence de migration SwiftData empêchent une soumission App Store sereine.
2. **Concurrence Swift 6** : les `ObservableObject` non annotés `@MainActor` deviendront des erreurs strictes ; à traiter avant que Swift 6 ne soit imposé.
3. **Dette d'industrialisation** : doublons app/widget, mélange FR/EN, absence d'accessibilité, absence de CI, couverture tests partielle.

Aucun de ces points n'est rédhibitoire ; tous sont **traitables en quelques jours-semaine** pour atteindre un niveau de qualité production. Le socle technique est suffisamment sain pour absorber l'évolution fonctionnelle ambitieuse esquissée par la roadmap (splits, notifications, plan IA, Apple Watch).

**Verdict** : projet sérieux, **prêt à passer en bêta privée** une fois les points critiques (3.1) corrigés ; à enrichir et industrialiser (3.2 / 3.3) avant la mise au public.

---

*Fin du rapport.*

