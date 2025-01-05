.mode trash

INSTALL httpfs;
LOAD httpfs;

Create secret s3logs (
    type s3,
    PROVIDER CREDENTIAL_CHAIN,
    ENDPOINT 'fly.storage.tigris.dev',
    REGION 'auto',
    URL_STYLE 'path'
);

.mode jsonlines
