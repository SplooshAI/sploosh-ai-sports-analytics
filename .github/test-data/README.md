# GitHub Actions Test Data

This directory contains test data files used for local testing of GitHub Actions workflows using [act](https://github.com/nektos/act).

## Directory Structure

- `pr-events/` - Contains example Pull Request event payloads
  - `major.json` - Example of a breaking change PR
  - `minor.json` - Example of a feature addition PR
  - `patch.json` - Example of a bug fix PR
  - `invalid.json` - Example of an invalid PR format
  - `merge.json` - Example of a PR merge event
