# AI Dev Base Template

This repository serves as a base template for a safe, standardized AI-coding environment using Dev Containers. 

It provides a consistent `.devcontainer` setup that can be merged into any existing or new project, ensuring you have your preferred tools, dotfiles, and configurations ready to go.

## How to use this template in an existing project

We use the **Template Remote** pattern. This allows you to pull the base setup into any project, and easily fetch updates if this base template improves over time.

1. Navigate to your existing project repository:
   ```bash
   cd my-existing-project
   ```
2. Add this repository as a new remote called `template` (replace the URL with your actual repository URL):
   ```bash
   git remote add template git@github.com:niilz/ai-dev-base.git
   ```
3. Fetch the template data:
   ```bash
   git fetch template
   ```
4. Merge the base setup into your project (allowing unrelated histories):
   ```bash
   git merge template/main --allow-unrelated-histories -m "Merge base devcontainer template"
   ```

**To update later:** When changes are pushed to this base template, you can pull them into your downstream projects by running:
```bash
git pull template main
```

## Running the Dev Container via Command Line

You don't need a specific IDE to use this environment. You can build and connect to it entirely from the terminal using the official [Devcontainer CLI](https://code.visualstudio.com/docs/remote/devcontainer-cli). 

If you don't have the CLI installed, you can get it via npm: `npm install -g @devcontainers/cli`.

### 1. Build and Start
To build the image and start the container based on your `.devcontainer` configuration:
```bash
devcontainer up --workspace-folder .
```
*(This command reads the configuration in your current directory, builds the Docker image if necessary, and starts the container in the background.)*

### 2. Connect (Exec)
To get a shell inside your running AI-coding environment, execute:
```bash
devcontainer exec --workspace-folder . /bin/bash
```
*(Note: If your base image uses a different default shell like `zsh`, replace `/bin/bash` with `/bin/zsh`)*

Once inside, your local workspace is mounted, your dotfiles are applied, and you are ready to start coding securely!
