# PR Plan for Issue #368: Add GHA Infrastructure for R Package Checks

## Issue Summary
Add GitHub Actions infrastructure for R package checks to the nfidd repository. The implementation should be based on the primarycensored-paper repository but use normal R setup instead of renv.

## Acceptance Criteria
1. Set up GitHub Actions workflows for R package checks
2. Include linting workflow
3. Include test coverage workflow
4. Use standard R setup (not renv)
5. Set up testing infrastructure (but no actual tests required)
6. Ensure workflows are compatible with the nfidd package structure

## Implementation Approach
1. Use existing `.github/workflows` directory
2. Adapt workflows from primarycensored-paper and r-lib/actions:
   - Use r-lib/actions standard R package check workflow
   - Convert lint workflow from renv to standard R setup
   - Convert test coverage workflow from renv to standard R setup
   - Include proper repository configuration for additional R repos
3. Set up testing infrastructure:
   - Create `tests/testthat` directory structure
   - Add testthat to Suggests in DESCRIPTION
   - Create basic test setup file
4. Ensure cmdstan installation is included (nfidd uses Stan models)
5. Use r-lib/actions for consistent R package CI/CD

## Files to Modify/Create
1. `.github/workflows/R-CMD-check.yaml` - Standard R package checks
2. `.github/workflows/lint.yaml` - Linting workflow
3. `.github/workflows/test-coverage.yaml` - Test coverage workflow
4. `tests/testthat.R` - Test runner
5. `tests/testthat/` - Test directory structure
6. `DESCRIPTION` - Add testthat to Suggests

## Testing Strategy
- Verify workflows syntax is correct
- Ensure all dependencies are properly installed
- Check that cmdstan is installed for Stan model compilation
- Verify test infrastructure is set up correctly

## Potential Edge Cases
- Stan model compilation requirements
- System dependencies for the package
- Ensuring workflows work across different OS versions
- Handling R package dependencies correctly without renv
- Need to include additional repositories (stan-dev, epiforecasts)
- Must handle roxyglobals for documentation

## Discovered Context
- `.github/workflows` directory already exists with deploy and README workflows
- Package heavily uses Stan models via cmdstanr
- No existing test infrastructure
- Uses additional R repositories for dependencies
- Requires R >= 4.2.0