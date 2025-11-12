# Contributing Guide

Thank you for your interest in contributing to the Mobile Internet project!

## Development Setup

### Prerequisites

Before you begin, ensure you have the following installed:

- **Java 17 or higher** - for backend development
- **Maven 3.6 or higher** - for building the backend
- **Node.js 18 or higher** - for frontend development
- **npm** - for managing frontend dependencies
- **Git** - for version control
- **DevEco Studio** - (optional) for HarmonyOS development

### Getting Started

1. **Clone the repository**
   ```bash
   git clone https://github.com/Pythia111/mobile-internet.git
   cd mobile-internet
   ```

2. **Set up the backend**
   ```bash
   cd backend
   mvn clean install
   cd ..
   ```

3. **Set up the frontend**
   ```bash
   cd web-frontend
   npm install
   cd ..
   ```

4. **Start development servers**
   ```bash
   ./start.sh
   ```

   Or manually:
   ```bash
   # Terminal 1 - Backend
   cd backend
   mvn spring-boot:run

   # Terminal 2 - Frontend
   cd web-frontend
   npm run dev
   ```

## Project Structure

```
mobile-internet/
├── backend/              # Spring Boot backend
├── web-frontend/         # Vue.js frontend
├── harmony-client/       # HarmonyOS client
├── SETUP_SUMMARY.md      # Detailed setup guide
├── README.md            # Project overview
└── start.sh             # Quick start script
```

## Development Workflow

### Backend Development

1. **Make your changes** in `backend/src/main/java/`
2. **Run tests**
   ```bash
   cd backend
   mvn test
   ```
3. **Check code quality**
   ```bash
   mvn verify
   ```
4. **Build**
   ```bash
   mvn clean install
   ```

### Frontend Development

1. **Make your changes** in `web-frontend/src/`
2. **Run linter**
   ```bash
   cd web-frontend
   npm run lint
   ```
3. **Run tests**
   ```bash
   npm run test
   ```
4. **Build**
   ```bash
   npm run build
   ```

### HarmonyOS Development

1. Open `harmony-client/` in DevEco Studio
2. Make your changes
3. Build and test in the IDE

## Code Style

### Backend (Java)
- Follow standard Java naming conventions
- Use meaningful variable and method names
- Add JavaDoc comments for public APIs
- Keep methods focused and small
- Use Lombok annotations when appropriate

### Frontend (TypeScript/Vue)
- Follow the Vue.js style guide
- Use TypeScript for type safety
- Use Composition API with `<script setup>`
- Keep components small and reusable
- Use meaningful component and variable names
- Run `npm run format` before committing

### HarmonyOS (ArkTS)
- Follow HarmonyOS development guidelines
- Use declarative UI patterns
- Keep components modular

## Testing

### Backend Tests
```bash
cd backend
mvn test                  # Run all tests
mvn test -Dtest=ClassName # Run specific test
```

### Frontend Tests
```bash
cd web-frontend
npm run test              # Run all tests
npm run test:unit         # Run unit tests
npm run test -- --watch   # Run in watch mode
```

## Adding New Features

### Adding a New Backend Endpoint

1. Create a new controller in `backend/src/main/java/.../controller/`
2. Add the endpoint method with proper annotations
3. Update the API service in `web-frontend/src/services/api.ts`
4. Create tests in `backend/src/test/java/`

Example:
```java
@RestController
@RequestMapping("/api")
public class UserController {
    @GetMapping("/users")
    public List<User> getUsers() {
        // Implementation
    }
}
```

### Adding a New Frontend Page

1. Create a new component in `web-frontend/src/views/`
2. Add a route in `web-frontend/src/router/index.ts`
3. Update navigation if needed

Example:
```typescript
// router/index.ts
{
  path: '/users',
  name: 'users',
  component: () => import('../views/UsersView.vue')
}
```

### Adding a HarmonyOS Page

1. Create a new `.ets` file in `harmony-client/entry/src/main/ets/pages/`
2. Add the page to `main_pages.json`
3. Implement the page UI

## Commit Guidelines

### Commit Message Format
```
<type>(<scope>): <subject>

<body>

<footer>
```

### Types
- **feat**: New feature
- **fix**: Bug fix
- **docs**: Documentation changes
- **style**: Code style changes (formatting, etc.)
- **refactor**: Code refactoring
- **test**: Adding or updating tests
- **chore**: Maintenance tasks

### Examples
```
feat(backend): add user authentication endpoint

Add JWT-based authentication to the backend API.
Includes login and token refresh endpoints.

Closes #123
```

```
fix(frontend): correct API endpoint URL

The health check endpoint was using the wrong URL.
Updated to use the correct /api/health endpoint.
```

## Pull Request Process

1. **Fork** the repository
2. **Create a branch** for your feature
   ```bash
   git checkout -b feature/your-feature-name
   ```
3. **Make your changes** and commit them
4. **Push** to your fork
   ```bash
   git push origin feature/your-feature-name
   ```
5. **Create a Pull Request** on GitHub
6. **Wait for review** and address any feedback

### PR Checklist
- [ ] Code follows the project style guidelines
- [ ] All tests pass
- [ ] New tests added for new features
- [ ] Documentation updated if needed
- [ ] Commit messages follow the guidelines
- [ ] No merge conflicts

## Common Issues and Solutions

### Backend won't start
- **Check Java version**: `java -version` (should be 17+)
- **Clean and rebuild**: `mvn clean install`
- **Check port**: Ensure port 8080 is not in use

### Frontend won't start
- **Check Node version**: `node --version` (should be 18+)
- **Reinstall dependencies**: `rm -rf node_modules && npm install`
- **Check port**: Ensure port 5173 is not in use

### Build fails
- **Backend**: Check Maven errors and dependencies
- **Frontend**: Run `npm run lint` to check for errors
- **Clear caches**: Delete `node_modules`, `target`, and reinstall

## Getting Help

- **Check the documentation**: See [README.md](README.md) and [SETUP_SUMMARY.md](SETUP_SUMMARY.md)
- **Search existing issues**: on GitHub
- **Create an issue**: if you find a bug or have a question
- **Ask for help**: in pull request comments

## Code of Conduct

- Be respectful and inclusive
- Welcome newcomers
- Focus on what's best for the project
- Show empathy towards others

## License

By contributing to this project, you agree that your contributions will be licensed under the same license as the project.

Thank you for contributing! 🎉
