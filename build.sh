#!/bin/bash
set -e

# get current script path
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# parse GitHub repository name from clone URL
GH_REGEX='https://github.com/maiatechio/(.+)\.git*'
export GITHUB_REPOSITORY=''
if [[ ${CODEBUILD_SOURCE_REPO_URL} =~ $GH_REGEX ]]; then
  export GITHUB_REPOSITORY=${BASH_REMATCH[1]}
fi

# determine branch
BRANCH=$(git rev-parse --abbrev-ref HEAD)

# increment version, even if everything is broken
${DIR}/gradlew release -Prelease.disableChecks -Prelease.pushTagsOnly -Prelease.ignoreUncommittedChanges

# publish all artifacts if their respective tests passed, CodeBuild will fail if all tasks do not pass
${DIR}/gradlew --continue test publishAllPublicationsToGitHubPackagesRepository -Prelease.ignoreUncommittedChanges
