# Price Alert Application

## Features
- User authentication with JWT.
- Create, view, and delete price alerts for various coins.
- Real-time price updates using Binance WebSocket.
- Caching of user alerts with Redis for faster responses.
- Alerts are printed in console when the target price is hit.

---

## Setup and Installation

### Prerequisites
- Docker and Docker Compose installed on your machine.

### Steps to Set Up the Project

1. Clone the repository:
   ```bash
   git clone https://github.com/akashkinwad/price_alert_app.git
   cd price_alert_app
   ```

2. Build and run the Docker containers:
   ```bash
   docker-compose up --build
   ```

3. Create Database and run migrations
   ```bash
   docker-compose run app bundle exec rake db:drop db:create db:migrate
   ```

4. Create seed data:
  - See the sidekiq console to see the latest price of the coin.
  - Replace 58000 with the price of the coin you want to create an alert for.
  ```bash
  docker-compose run app bundle exec rake "create_user_alerts:create[58000]"
   ```

5. Output Logs
  - Step 4 will print the created user token
  - This will be used in API endpoints

---

## API Endpoints

### Create Alert
- **Endpoint**: `POST /alerts/create`
- **Description**: Creates a new price alert for the authenticated user.
- **Headers**:
  - `Authorization`: `JWT_TOKEN`
- **Request Body**:
  ```json
  {
    "coin_name": "BTC",
    "target_price": 60000
  }
  ```

### List Alerts
- **Endpoint**: `GET /alerts`
- **Description**: Fetches all alerts created by the authenticated user, with optional filtering by status and pagination.
- **Headers**:
  - `Authorization`: `JWT_TOKEN`
- **Query Parameters**:
  - `status` (optional): Filter alerts by their status (e.g., `created`, `triggered`, `deleted`). Default is `all`.
  - `page` (optional): Specify the page number for paginated results. Default is `1`.
- **Response**:
  ```json
  {
    "alerts": [
      {
        "id": 1,
        "coin_name": "BTC",
        "target_price": 60000,
        "status": "created",
        "user_id": 1,
        "created_at": "2024-09-16T09:05:44.309Z",
        "updated_at": "2024-09-16T09:05:44.309Z"
      },
      {
        "id": 2,
        "coin_name": "ETH",
        "target_price": 2000,
        "status": "created",
        "user_id": 1,
        "created_at": "2024-09-16T09:06:44.309Z",
        "updated_at": "2024-09-16T09:06:44.309Z"
      }
    ],
    "meta": {
      "current_page": 1,
      "next_page": null,
      "prev_page": null,
      "total_pages": 1,
      "total_count": 2
    }
  }

### Delete Alert
- **Endpoint**: `DELETE /alerts/{{alert_id}}`
- **Description**: Delete a price alert
- **Headers**:
  - `Authorization`: `JWT_TOKEN`

---

## Solution for Sending Alerts

#### Service Class for Triggering Alerts

A dedicated service class, PriceAlertService, checks whether the current currency price meets the target prices specified by users. Once an alert is triggered, its status is updated, and a list of user_ids is generated for notifying the respective users.
- Process:
  - Fetch all alerts where the coin_name matches and status is created and trigger price.
  - Update the alert’s status to triggered.
  - Collect the relevant user_ids and pass them to a background job for sending email notifications.

#### Asynchronous Email Notifications:
- Email notifications are handled asynchronously via ActiveJob, ensuring the primary application flow remains uninterrupted.
