# Requirements Verification Questions — dbp-visitor Plugin

Please answer the following questions to help clarify the requirements for the `dbp-visitor` floating welcome bar plugin.

## Question 1
How should the plugin determine "where the visitor came from"?

A) HTTP Referer header (e.g., "You came from Google", "You came from Facebook")
B) Geolocation via IP (e.g., "Welcome visitor from New York!")
C) Both — show referrer source AND geographic location
D) UTM parameters (e.g., campaign source tracking)
X) Other (please describe after [Answer]: tag below)

[Answer]: C

## Question 2
What does "how they've been" mean in context? How should we determine/display this?

A) Returning visitor detection via cookie/localStorage (e.g., "Welcome back! Last visit was 3 days ago")
B) Visit count tracking (e.g., "Welcome back for your 5th visit!")
C) Both — show last visit time AND total visit count
D) Simple greeting only — no tracking, just a friendly message like "Hope you're doing well!"
X) Other (please describe after [Answer]: tag below)

[Answer]: B

## Question 3
On which pages should the floating bar appear?

A) All pages (entire site)
B) Homepage only
C) All pages except admin area
D) Configurable via admin settings
X) Other (please describe after [Answer]: tag below)

[Answer]: C

## Question 4
Should the dismiss state (when user closes with X or Esc) persist across page loads?

A) Yes — once dismissed, stay hidden for the entire session (until browser close)
B) Yes — once dismissed, stay hidden for a set period (e.g., 24 hours, 7 days)
C) No — show again on every page load (dismissed only for current page view)
X) Other (please describe after [Answer]: tag below)

[Answer]: A

## Question 5
Should the plugin have admin settings (like the hello-bar plugin)?

A) Yes — allow customizing the welcome message text, colors/theme, and behavior
B) Minimal — just an enable/disable toggle
C) No admin settings — hardcoded defaults only
X) Other (please describe after [Answer]: tag below)

[Answer]: B

## Question 6
Should this plugin follow the same strict CSP compliance as the hello-bar plugin (no inline styles/scripts)?

A) Yes — strict CSP compliance (external CSS/JS files only)
B) No — inline styles/scripts are acceptable
X) Other (please describe after [Answer]: tag below)

[Answer]: A

## Question 7: Security Extensions
Should security extension rules be enforced for this project?

A) Yes — enforce all SECURITY rules as blocking constraints (recommended for production-grade applications)
B) No — skip all SECURITY rules (suitable for PoCs, prototypes, and experimental projects)
X) Other (please describe after [Answer]: tag below)

[Answer]: A

## Question 8: Property-Based Testing Extension
Should property-based testing (PBT) rules be enforced for this project?

A) Yes — enforce all PBT rules as blocking constraints (recommended for projects with business logic, data transformations, serialization, or stateful components)
B) Partial — enforce PBT rules only for pure functions and serialization round-trips (suitable for projects with limited algorithmic complexity)
C) No — skip all PBT rules (suitable for simple CRUD applications, UI-only projects, or thin integration layers with no significant business logic)
X) Other (please describe after [Answer]: tag below)

[Answer]: B
