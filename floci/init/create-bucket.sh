#!/usr/bin/env sh
set -eu

# Creates the bucket in the local floci (S3-compatible) object storage.
# Only used by the bundled `local-infra` profile / Helm local-storage job.
# When bringing your own S3-compatible storage, create the bucket there instead.

bucket="${FLOCI_BUCKET:-rtylr-self-host}"
endpoint="${AWS_ENDPOINT_URL:-${S3_ENDPOINT:-http://floci:4566}}"

# Wait for the endpoint to accept requests, then create the bucket idempotently.
i=0
until aws --endpoint-url "$endpoint" s3 mb "s3://${bucket}" >/dev/null 2>&1 || \
      aws --endpoint-url "$endpoint" s3 ls "s3://${bucket}" >/dev/null 2>&1; do
  i=$((i + 1))
  if [ "$i" -ge 30 ]; then
    echo "floci endpoint ${endpoint} not ready after 30 attempts" >&2
    exit 1
  fi
  sleep 2
done

echo "floci bucket ${bucket} ready at ${endpoint}"
