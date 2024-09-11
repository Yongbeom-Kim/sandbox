# S3 Website Example
This is an example of how to host a static website on S3. This example uses terraform to create the S3 bucket, enable static website hosting, and upload the website files, with configuration of a CloudFront distribution + Route53 domain to serve the website.

The frontend is the sample website from `yarn create vite`.

## Scripts

To deploy, do the following:

```bash
yarn # install dependencies
yarn run deploy:infra
yarn run deploy:code
```

To destroy deployment, do the following

```bash
yarn run destroy:infra
yarn run destroy:code
```
