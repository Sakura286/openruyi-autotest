# Functional test - Package tests

This directory contains functional test cases for each package, Uses ACL sub-directory structure standard.

## Test coverage overview

- **202 packages**, **561 test cases**, **1,692 functional points**
- All test scripts have been verified on openEuler RISC-V server
- See [Functional test coverage details](../../docs/coverage/functional-coverage.md)

## directory structure

```
tests/functional/
├── main.fmf # Shared configuration (All subdirectories inherit)
├── README.md # this file
└── pkgs/ # RPM Package functional tests
 ├── main.fmf # Shared configuration
 ├── acl/ # acl Package tests (Reference standard)
 │ ├── main.fmf
 │ ├── test.sh
 │ └── test_acl_*/ # Sub-test directories
 ├── attr/ # attr Package tests
 │ ├── main.fmf
 │ ├── test.sh
 │ └── test_attr_*/ # Sub-test directories
 └──... # More package tests
```

## Test structure specification (Refer to ACL)

Each package test directory contains:
- `main.fmf` -- Package-level metadata configuration
- `test.sh` -- Package-level main test script
- `test_<pkg>_<feature>/` -- Sub-test directories split by functional point
 - `main.fmf` -- Sub-test metadata
 - `test.sh` -- Sub-test script

## Add new package test

1. Create directory `tests/functional/pkgs/<package_name>/`
2. create `main.fmf` (Refer to `pkgs/acl/main.fmf`)
3. create `test.sh` (Refer to template)
4. Create sub-test directories by functional point

## Run tests

```bash
tmt run plan --name /plans/functional test --name /tests/functional/<package_name>
```
- Metadata files are uniformly named `main.fmf`

## Test coverage progress

| soft | Status | Number of test cases | Notes |
|--------|------|-----------|------|
| acl | ✅ Complete | 27+ | First example package |
|... | To be added | - | - |

## Reference documentation

- Package test writing guide:`.trellis/tasks/06-09-acl/package-test-guide.md`
- tmt Official documentation:https://tmt.readthedocs.io/
