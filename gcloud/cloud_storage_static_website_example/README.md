# Google Cloud Storage - Static Website Hosting Example
This is an example of how to host a static website (Vite template) on Google Cloud Storage, with the relevant DNS, SSL, and CDN/Load Balancer configurations.

## Prerequisites
- Google Cloud SDK (`gcloud` CLI)
- OpenTofu
- Yarn

## Usage
Here are the pre-Terraform steps:
1. Create a Google Cloud project.
2. Make sure you have a hosted zone of a domain in Google Cloud DNS.
3. Create a service account with the relevant permissions (Storage Admin, DNS Admin, etc.) and download the JSON key.
4. Copy the JSON key to `./gcloud_auth/config.json`

To deploy the website, run the following commands:
```sh
make deploy # You will need to wait for an hour for the certificate verification + provisioning.
```
To destroy the resources, run the following commands:
```sh
make destroy
```

Note that due to dependencies in Google Cloud's Load Balancer, it may not be possible to deploy modifications to the infrastructure if you change something. In that case, you may need to destroy the resources and redeploy them.

Below is the original README of the Vite template.

## React + TypeScript + Vite

This template provides a minimal setup to get React working in Vite with HMR and some ESLint rules.

Currently, two official plugins are available:

- [@vitejs/plugin-react](https://github.com/vitejs/vite-plugin-react/blob/main/packages/plugin-react/README.md) uses [Babel](https://babeljs.io/) for Fast Refresh
- [@vitejs/plugin-react-swc](https://github.com/vitejs/vite-plugin-react-swc) uses [SWC](https://swc.rs/) for Fast Refresh

### Expanding the ESLint configuration

If you are developing a production application, we recommend updating the configuration to enable type aware lint rules:

- Configure the top-level `parserOptions` property like this:

```js
export default tseslint.config({
  languageOptions: {
    // other options...
    parserOptions: {
      project: ['./tsconfig.node.json', './tsconfig.app.json'],
      tsconfigRootDir: import.meta.dirname,
    },
  },
})
```

- Replace `tseslint.configs.recommended` to `tseslint.configs.recommendedTypeChecked` or `tseslint.configs.strictTypeChecked`
- Optionally add `...tseslint.configs.stylisticTypeChecked`
- Install [eslint-plugin-react](https://github.com/jsx-eslint/eslint-plugin-react) and update the config:

```js
// eslint.config.js
import react from 'eslint-plugin-react'

export default tseslint.config({
  // Set the react version
  settings: { react: { version: '18.3' } },
  plugins: {
    // Add the react plugin
    react,
  },
  rules: {
    // other rules...
    // Enable its recommended rules
    ...react.configs.recommended.rules,
    ...react.configs['jsx-runtime'].rules,
  },
})
```
