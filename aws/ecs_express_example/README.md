# AWS ECS Express Example

Sample project to demonstrate how to deploy an Express.js application to AWS ECS.

Inspired by this [tutorial](https://youtu.be/ngupV3Y_fvw?si=2rSqcrI0ddP-7ZnD) by AWS With Atiq.

## Running the Express App Locally

To see the scripts involved in running the Express app locally, check the `scripts` section in `package.json`.

### Prerequisites
- Node.js
- npm
- yarn
- docker

### Steps (Local)
1. Install dependencies
    ```bash
    yarn
    ```
2. Start the Express app with a non-priviliged port
    ```bash
    PORT=3030 yarn start
    ```
3. Open a browser and navigate to `http://localhost:3030`
4. You should see the message `Hello World!`

### Steps (Docker)
1. Build the Docker image
    ```bash
    yarn docker:build
    ```
2. Run the Docker container
    ```bash
    yarn docker:run
    ```
3. Open a browser and navigate to `http://localhost:80`
4. Alternatively, make a GET request to `http://localhost:80` using `curl` or `Postman`
    ```bash
    # Using the script in package.json
    yarn docker:get_request
    # Using curl
    curl http://localhost:80
    ```
5. To kill the container, run
    ```bash
    yarn docker:kill
    ```