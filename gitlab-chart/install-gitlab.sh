#!/usr/bin/env bash

set -e -o pipefail

if [ -z ${ENVIRO} ]; 
then 
    echo "var ENVIRO is unset "
    exit 0
else 
    echo " creating for $ENVIRO environment..."
fi

export DATABASE_URL=$(cd ./terraform && exec terraform output -json | jq .this_db_instance_endpoint.value | cut -f1 -d":" | cut -c2- ; cd ~-)
export REGION=$(cat ./terraform/terraform-$ENVIRO.tfvars | grep REGION | cut -f2 -d"=" |  cut -d'"' -f2)
export ELASTICACHE_URL=$(cd ./terraform && exec terraform output -json | jq .elasticache_instance.value | cut -f1 -d":" | cut -d'"' -f2 ; cd ~-)
export DOMAIN="yourdomain"
export COMPANHY="yourcompanhy"
export EMAIL_CERT="youremailforcertificate"
export NS=$ENVIRO-gitlab

if [ "$ENVIRO" == "staging" ]
then
    export URL_GITLAB=homolog.$DOMAIN
    export URL_REGISTRY_GITLAB=registry-homolog.$DOMAIN
    export CRON_BKP="0 0 1 * *"
    echo $NS
else
    export URL_GITLAB=$DOMAIN
    export URL_REGISTRY_GITLAB=registry.$DOMAIN
    export CRON_BKP="0 1 * * *"
    echo $NS
fi

# Install Gitlab
helm repo add gitlab https://charts.gitlab.io/
helm repo update 
helm upgrade --install --version 2.2.5 $NS gitlab/gitlab --namespace $NS --timeout "2000s" \
    --set global.hosts.domain=$DOMAIN \
    --set certmanager.install=false \
    --set certmanager-issuer.email=$EMAIL_CERT \
    --set global.edition=ce \
    --set global.hosts.gitlab.name=$URL_GITLAB \
    --set global.hosts.registry.name=$URL_REGISTRY_GITLAB \
    --set global.ingress.configureCertmanager=false \
    --set nginx-ingress.enabled=false \
    --set global.ingress.class=nginx \
    --set global.ingress.tls.secretName=letsencrypt-prod \
    --set global.ingress.annotations."certmanager\.k8s\.io/cluster-issuer"=letsencrypt-prod \
    --set global.ingress.annotations."kubernetes\.io/tls-acme"=true \
    --set gitlab.unicorn.ingress.tls.secretName=$NS-gitlab-tls \
    --set registry.ingress.tls.secretName=$NS-registry-tls \
    --set minio.ingress.tls.secretName=$NS-minio-tls \
    --set global.minio.enabled=false \
    --set global.psql.host=$DATABASE_URL \
    --set global.psql.database=gitlab \
    --set global.psql.username=gitlab \
    --set global.psql.password.secret=gitlab-postgresql-password \
    --set redis.enabled=false \
    --set sidekiq.memoryKiller.maxRss=0 \
    --set global.redis.host=$ELASTICACHE_URL \
    --set global.redis.password.enabled=false \
    --set gitlab.task-runner.backups.objectStorage.config.secret=storage-config \
    --set gitlab.task-runner.backups.objectStorage.config.key=config \
    --set gitlab.task-runner.backups.cron.enabled=true \
    --set gitlab.task-runner.backups.cron.schedule="$CRON_BKP" \
    --set gitlab.task-runner.backups.cron.extraArgs="--skip registry --skip artifacts" \
    --set gitlab.task-runner.backups.cron.persistence.enabled=true \
    --set gitlab.task-runner.persistence.enabled=false \
    --set gitlab.task-runner.persistence.size=30Gi \
    --set postgresql.install=false \
    --set global.psql.password.key=postgres-password \
    --set global.registry.bucket=gitlab-registry-storage-$COMPANHY-$ENVIRO \
    --set registry.storage.secret=registry-storage \
    --set registry.storage.key=config \
    --set registry.debug.prometheus.enabled=true \
    --set registry.debug.prometheus.path=/metrics \
    --set global.smtp.enabled=true \
    --set global.smtp.address=smtp.sendgrid.net \
    --set global.smtp.port=587 \
    --set global.smtp.user_name=apikey \
    --set global.smtp.password.secret=smtp-pass \
    --set global.smtp.password.key=smtp-pass \
    --set global.smtp.authentication=login \
    --set global.smtp.starttls_auto=true \
    --set global.smtp.openssl_verify_mode=none \
    --set global.email.from=no-reply@youremail.com \
    --set global.email.display_name="Gitlab Your Companhy" \
    --set global.email.reply_to=no-reply@youremail.com \
    --set global.email.subject_suffix=Gitlab \
    --set gitlab-runner.runners.builds.cpuLimit=700m \
    --set gitlab-runner.runners.builds.memoryLimit=1024Mi \
    --set gitlab-runner.runners.builds.cpuRequests=400m \
    --set gitlab-runner.runners.builds.memoryRequests=512Mi \
    --set gitlab-runner.resources.requests.cpu=400m \
    --set gitlab-runner.resources.limits.cpu=700m \
    --set gitlab-runner.resources.requests.memory=512Mi \
    --set gitlab-runner.resources.limits.memory=1024Mi \
    --set gitlab-runner.runners.cache.cacheType=s3 \
    --set gitlab-runner.runners.cache.s3BucketName=gitlab-runner-cache-$COMPANHY-$ENVIRO \
    --set gitlab-runner.runners.cache.s3BucketLocation=$REGION \
    --set gitlab-runner.runners.cache.secretName=$ENVIRO-gitlab-gitlab-runner-secret \
    --set global.appConfig.lfs.bucket=gitlab-lfs-storage-$COMPANHY-$ENVIRO \
    --set global.appConfig.lfs.connection.secret=gitlab-bucket-config \
    --set global.appConfig.lfs.connection.key=config \
    --set global.appConfig.artifacts.bucket=gitlab-artifacts-storage-$COMPANHY-$ENVIRO \
    --set global.appConfig.artifacts.connection.secret=gitlab-bucket-config \
    --set global.appConfig.artifacts.connection.key=config \
    --set global.appConfig.uploads.bucket=gitlab-uploads-storage-$COMPANHY-$ENVIRO \
    --set global.appConfig.uploads.connection.secret=gitlab-bucket-config \
    --set global.appConfig.uploads.connection.key=config \
    --set global.appConfig.packages.bucket=gitlab-packages-storage-$COMPANHY-$ENVIRO \
    --set global.appConfig.packages.connection.secret=gitlab-bucket-config \
    --set global.appConfig.packages.connection.key=config \
    --set global.appConfig.externalDiffs.enabled=true \
    --set global.appConfig.externalDiffs.bucket=gitlab-externaldiffs-storage-$COMPANHY-$ENVIRO \
    --set global.appConfig.externalDiffs.when=outdated \
    --set global.appConfig.externalDiffs.connection.secret=gitlab-bucket-config \
    --set global.appConfig.externalDiffs.connection.key=config \
    --set global.appConfig.pseudonymizer.bucket=gitlab-pseudonymizer-storage-$COMPANHY-$ENVIRO \
    --set global.appConfig.pseudonymizer.connection.secret=gitlab-bucket-config \
    --set global.appConfig.pseudonymizer.connection.key=config \
    --set global.appConfig.backups.bucket=gitlab-backup-storage-$COMPANHY-$ENVIRO \
    --set global.appConfig.backups.tmpBucket=gitlab-tmp-storage-$COMPANHY-$ENVIRO \
    --set gitlab-runner.runners.privileged=true \
    --set gitlab-runner.runners.pollTimeout=3600 \
    --set gitlab-runner.concurrent=30 \
    --set prometheus.install=true \
    --set global.grafana.enabled=true 
   
# if want enable oauth...
#--set global.appConfig.omniauth.enabled=true \
#--set global.appConfig.omniauth.blockAutoCreatedUsers=true \
#--set global.appConfig.omniauth.allowSingleSignOn[0]='google_oauth2' \
#--set global.appConfig.omniauth.providers[0].secret=google-oauth2 \
#--set global.ingress.annotations."custom\.nginx\.org/rate-limiting="on \
#--set global.ingress.annotations."custom\.nginx\.org/rate-limiting-rate="90/s \





