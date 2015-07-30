#!/bin/bash

set -e

# 1. Fetch token for admin
# 2. Create user
# 3. Create namespace
# 4. Create collection
# 5. Fetch Certificate
# 6. Fetch token for user created in #2
# 7. Write configuration files
# 8. Run tests

([ -z $UAA_ADMIN_IDENTITY ] || [ -z $UAA_ADMIN_PASSWORD ] || [ -z $UAA_URL ] || [ -z $SYSTEM_DOMAIN ]) && echo "Missing environment variables" && exit 1

export username=$(uuidgen)
export password=$(uuidgen)
export namespace=$(uuidgen)
export collection=$(uuidgen)

auth_url=https:\/\/datasync-authentication.$SYSTEM_DOMAIN
data_url=https:\/\/datasync-datastore.$SYSTEM_DOMAIN

echo ""
echo "======================================================"
echo "1. Fetch token for admin"
echo "======================================================"
echo ""

authorization_header_uaa="Authorization: Basic $(printf "cf:" | base64)"
payload_uaa="username=$UAA_ADMIN_IDENTITY&password=$UAA_ADMIN_PASSWORD&scope=openid&grant_type=password"

admin_token=$(curl -sk $UAA_URL/oauth/token -X POST -H "$authorization_header_uaa" -d "$payload_uaa" | jq '.access_token' | awk -F '"' '{print $2}')

echo ""
echo "======================================================"
echo "2. Create user"
echo "======================================================"
echo ""

(
content_type_header="Content-Type: application/json"
authorization_header="Authorization: Bearer $admin_token"
payload="{\"username\" : \"$username\", \"password\" : \"$password\"}"

curl -sk $auth_url/api/users -X POST -H "$authorization_header" -H "$content_type_header" -d "$payload"
)

echo ""
echo "======================================================"
echo "3. Create namespace"
echo "======================================================"
echo ""

(
authorization_header="Authorization: Bearer $admin_token"
payload="{\"name\" : \"$namespace\"}"

curl -sk $data_url/admin/namespaces -X POST -H "$authorization_header" -d "$payload"
)

echo ""
echo "======================================================"
echo "4. Create collection"
echo "======================================================"
echo ""

(
authorization_header="Authorization: Bearer $admin_token"
payload="{\"name\" : \"$collection\"}"

curl -sk $data_url/admin/namespaces/$namespace/collections -X POST -H "$authorization_header" -d "$payload"
)

echo ""
echo "======================================================"
echo "5. Fetch certificate"
echo "======================================================"
echo ""

cert_path=$(dirname $0)/../data-demo/src/main/assets/cert.der

$(dirname $0)/get-certificates.sh *.$SYSTEM_DOMAIN:443 $cert_path

echo ""
echo "======================================================"
echo "6. Fetch token for user"
echo "======================================================"
echo ""

client_id=android-client
client_secret=2bf69b535d7ea2f9703ad5529b8cb05188b8dfaaeb9da48242d44373d8838cb7
payload_auth="username=$username&password=$password&scope=openid&grant_type=password&client_id=$client_id&client_secret=$client_secret"

access_token=$(curl -sk $auth_url/token -X POST -d "$payload_auth" | jq '.access_token' | awk -F '"' '{print $2}')

echo ""
echo "======================================================"
echo "7. Write configuration files"
echo "======================================================"
echo ""

cat > $(dirname $0)/../data-demo/src/main/assets/pivotal.properties << EOM
pivotal.auth.tokenUrl=$auth_url/token
pivotal.auth.clientId=$client_id
pivotal.auth.clientSecret=$client_secret
pivotal.auth.scopes=openid offline_access

pivotal.auth.accountType=io.pivotal.android.demo.account
pivotal.auth.tokenType=io.pivotal.android.demo.token

pivotal.data.serviceUrl=$data_url/data/$namespace
pivotal.data.collisionStrategy=OptimisticLocking

pivotal.auth.authorizeUrl=$auth_url/authorize
pivotal.auth.redirectUrl=io.pivotal.android.data://identity/oauth2callback
pivotal.auth.tokenType=io.pivotal.android.demo.token
pivotal.data.trustAllSslCertificates=false
pivotal.data.pinnedSslCertificateNames=$(basename $cert_path)
pivotal.auth.pinnedSslCertificateNames=$(basename $cert_path)
EOM

echo ""
echo "======================================================"
echo "8. Run tests"
echo "======================================================"
echo ""

./gradlew --refresh-dependencies clean assemble

gem install calabash-android

calabash-android run ./data-demo/build/outputs/apk/data-demo-debug.apk
