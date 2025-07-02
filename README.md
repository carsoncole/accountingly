# Accountingly

## Description
Accountingly is an application designed to help users manage financial accounts efficiently. It provides tools for tracking expenses, managing budgets, and generating income statements and balance sheet reports.

## Table of Contents
- [Installation](#installation)
- [Usage](#usage)
- [Contributing](#contributing)
- [License](#license)

## Installation
To install Accountingly, follow these steps:

```bash
git clone https://github.com/yourusername/accountingly.git
cd accountingly
bundle install
```

## Usage
To run the application, use the following command:

```bash
rails server
```

Visit `http://localhost:3000` in your web browser to access the application.

## Deployment

[Kamal](https://kamal-deploy.org) can be used for deployment. Configure `deploy.yml`. Kamal utilizes `DOCKERFILE` which is configured for utilizing PostgreSQL as its database. 

Create a Kamal secrets file `.kamal/secrets` . An example file is `.kamal/secrets-example`. Add your Docker password.


To deploy:
```ruby
kamal setup
kamal details
kamal deploy
```

## Contributing
We welcome contributions from the community. To contribute, please follow these steps:

1. Fork this repository.
2. Create a new branch (`git checkout -b feature/YourFeatureName`).
3. Make your changes and commit them (`git commit -m 'Add some feature'`).
4. Push to the branch (`git push origin feature/YourFeatureName`).
5. Open a pull request.

## License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

Copyright 2025 Carson Cole