#!/bin/bash

set -x
set -e

source acceptanceconfig

cat > ./data-demo/src/main/assets/pivotal.properties << EOM
pivotal.auth.tokenUrl=$DATA_ACCEPTANCE_AUTH_URL/token
pivotal.auth.clientId=$DATA_ACCEPTANCE_CLIENT_ID
pivotal.auth.clientSecret=$DATA_ACCEPTANCE_CLIENT_SECRET
pivotal.auth.scopes=openid offline_access

pivotal.auth.accountType=io.pivotal.android.demo.account
pivotal.auth.tokenType=io.pivotal.android.demo.token

pivotal.data.serviceUrl=$DATA_ACCEPTANCE_BACKEND_URL/data/$DATA_ACCEPTANCE_NAMESPACE
pivotal.data.collisionStrategy=OptimisticLocking
EOM

./gradlew --refresh-dependencies clean assemble

gem install calabash-android

calabash-android run ./data-demo/build/outputs/apk/data-demo-debug.apk
