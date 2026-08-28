## Package plan overview

Currently, MOSuite contains a multiOmicDataSet class (MO Ojbect / "moo") that is
the backbone of the package for storing data and analysis results.
I want to move the class definition to a new package, MOObject.
MOObject should contain the class definition, its helper functions such as
constructors, readers, and writers, and validators.
The purpose of moving this to MOObject is to allow packages that only need to
read/write multiOmicDataSet objects can just depend on MOObject without needing
MOSuite and all of its dependencies.
The main functionality should remain in MOSuite.
MOObject should be lightweight and fast.

## Implementation details

### 1) Define package boundaries

- MOObject responsibilities:
	- Define and export the S7 class `multiOmicDataSet`.
	- Define and export core generics needed to interact with the object.
	- Implement object-focused helpers only: constructors, validators, readers, and writers.
	- Keep dependencies minimal (prefer base + S7 + lightweight IO packages only).
- MOSuite responsibilities:
	- Keep analysis, modeling, plotting, normalization, filtering, and reporting functions.
	- Import and operate on `multiOmicDataSet` from MOObject.
- Non-goal:
	- Do not move analysis workflows into MOObject.

### 2) Inventory current `multiOmicDataSet` code in MOSuite

- Locate all class-related code in MOSuite:
	- class definition
	- property accessors/replacement methods
	- constructors and coercion helpers
	- validity checks
	- IO methods (read/write/serialize)
	- related generics and methods
- Build a migration table with columns:
	- `symbol`
	- `current_file`
	- `target_package` (MOObject or MOSuite)
	- `target_file`
	- `notes`

### 3) Implement MOObject core object layer

- Add R source files in MOObject for:
	- class definition (`multiOmicDataSet`)
	- constructor(s)
	- validation helpers
	- readers/writers
	- object generics/methods that are object-management only
- Code should be copy-pasted from MOSuite and only modified minimally, if at all.
- Add roxygen2 docs for all exported and internal functions.
- Ensure internal helpers include `@keywords internal`.
- Keep one logical return per function and follow tidyverse style.

### 4) Add package metadata and exports in MOObject

- Update `DESCRIPTION`:
	- add minimal required Imports/Suggests
	- ensure package title/description emphasize lightweight object + IO scope
- `NAMESPACE` is updated by `devtools::document()`.
- Add package-level documentation if needed.

### 5) Add tests in MOObject

- Create `testthat` coverage for:
	- successful object creation with valid inputs
	- informative errors for invalid inputs
	- object validity after slot/property updates
	- read/write round-trip integrity
	- backwards compatibility for serialized objects (if applicable)
- Use compact test data fixtures and avoid heavy dependencies.

### 6) Refactor MOSuite to consume MOObject

- Add MOObject as an Imports dependency in MOSuite `DESCRIPTION`.
- Remove duplicated class and object-IO code from MOSuite.
- Replace internal class references with MOObject exports.
- Keep existing MOSuite analysis APIs stable where possible.
- If any user-facing behavior changes, document them in NEWS/changelog.

### 7) Documentation updates

- MOObject:
	- add/update README with object creation and read/write examples
	- include a minimal vignette focused on object lifecycle (create -> validate -> save/load)
- MOSuite:
	- update README/vignettes to show MOObject-backed object creation paths
	- update references to class location and package dependency expectations

### 8) Compatibility and migration safeguards

- Preserve constructor names and core object access patterns where feasible.
- Add deprecation wrappers in MOSuite (if needed) for moved functions, with clear warnings.
- Provide a migration note mapping old MOSuite object utilities to MOObject equivalents.

### 9) Validation checklist before PRs

- MOObject:
	- run formatting/linting (`air format .`, `lintr`)
	- run unit tests (`testthat`)
	- run package checks (`devtools::check()`)
- MOSuite:
	- run formatting/linting (`air format .`, `lintr`)
	- run unit tests (`testthat`)
	- run package checks (`devtools::check()`)
	- verify no regressions in object-consuming analysis functions

### 10) Delivery strategy

- Preferred sequencing:
	1. Implement and test MOObject object layer first.
	2. Release or pin a development ref of MOObject.
	3. Refactor MOSuite to depend on MOObject.
	4. Run end-to-end checks in both repositories.
- PR structure:
	- PR 1 (MOObject): introduce class/generics/helpers/tests/docs.
	- PR 2 (MOSuite): remove duplicated object layer, import MOObject, adjust tests/docs.

### 11) Acceptance criteria

- `multiOmicDataSet` class is defined only in MOObject.
- MOObject can create, validate, save, and load objects without MOSuite installed.
- MOSuite analysis functions work with MOObject-defined objects without API regressions.
- Both repositories pass tests, linting, and package checks.
- Documentation in both repositories clearly reflects the new package boundary.
