# Integration Testing Guide

## 1. Backend Setup (Required)

The backend must be running for integration tests to work against the live API.

1.  **Start the Backend**:
    Open a terminal in `c:\DevProjects\backend-new-cogni` and run:
    ```bash
    ./gradlew run
    ```
    Ensure it is running on `localhost:8080`.

2.  **Backend Unit Tests**:
    To run the backend unit tests (which now have `DEV_MODE=true` configured automatically):
    ```bash
    ./gradlew test
    ```

## 2. Frontend Integration Tests

The integration tests are located in `integration_test/app_test.dart`.

1.  **Install Dependencies**:
    ```bash
    cd c:\DevProjects\StudioProjects\segundo_cogni
    flutter pub get
    ```

2.  **Run Integration Tests (Windows)**:
    To run the test on your Windows desktop:
    ```bash
    flutter test integration_test/app_test.dart -d windows
    ```

## Troubleshooting

*   **Backend Connection**: Ensure `BACKEND_URL` in your `.env` (or `.env.example` if `.env` is missing) matches the running backend URL.
*   **Database**: The integration test uses the real database. Ensure your local database is in a clean state if necessary.
