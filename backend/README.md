# Mobile Internet Backend

Spring Boot backend application for the Mobile Internet project.

## Technologies

- Java 17
- Spring Boot 3.2.0
- Spring Data JPA
- H2 Database (in-memory for development)
- Maven

## Getting Started

### Prerequisites

- Java 17 or higher
- Maven 3.6 or higher

### Running the Application

```bash
# Build the project
mvn clean install

# Run the application
mvn spring-boot:run
```

The application will start on `http://localhost:8080`

### Available Endpoints

- `GET /api/hello` - Simple hello endpoint
- `GET /api/health` - Health check endpoint
- `GET /h2-console` - H2 database console (development only)

### H2 Database Console

Access the H2 console at: `http://localhost:8080/h2-console`

- JDBC URL: `jdbc:h2:mem:testdb`
- Username: `sa`
- Password: (leave empty)

## Development

The application uses Spring Boot DevTools for hot reloading during development.

## Testing

```bash
mvn test
```
