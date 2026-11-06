# Billetto Events Ingestion & Voting Application

A Ruby on Rails application that ingests public events from the Billetto API, manages event voting using an Event-Sourced architecture via Rails Event Store, and restricts user actions through Clerk authentication.

---

## 1. Setup Instructions

### Prerequisites
* Ruby 3.3+
* PostgreSQL 14+
* Node.js & Bundler

### Environment Configuration
Create a `.env` file in the root directory:

```env
BILLETTO_BASE_URL="[https://billetto.co.uk/api/v3/public/](https://billetto.co.uk/api/v3/public/)"
BILLETTO_API_KEY="your_billetto_api_key"
BILLETTO_API_SECRET="your_billetto_api_secret"

CLERK_PUBLISHABLE_KEY="pk_test_..."
CLERK_SECRET_KEY="sk_test_..."
```

# installation

# 1. Install dependencies
bundle install

# 2. Database setup & migrations
bin/rails db:create db:migrate

# 3. Sync events from Billetto API
bin/rails billetto:sync_events

# 4. Start the server
bin/rails server

Visit http://localhost:3000 to view the events.

## 2 Running Tests

# Run all specs (Models, Requests, Event Store, and System tests)
bundle exec

## 3. Design Choices & Architecture

### 3.1 CQRS with Rails Event Store (RES)

- **Immutable Domain Events:** Votes are recorded as immutable domain events:
  - `Events::EventUpvoted`
  - `Events::EventDownvoted`
- **Auditability:** Each vote event stores the associated `user_id` and timestamp, providing a complete audit trail.
- **Denormalized Counters:** To avoid recalculating event stream aggregates on every page load (O(N) projection reads), a dedicated synchronous subscriber/projection (`Projections::EventVotesCounter`) maintains denormalized counters (`upvotes_count` and `downvotes_count`) directly on the `events` table.

### 3.2 External API Resilience

- **Separation of Concerns:** Separated the HTTP transport layer (`Billetto::Client`) from data persistence (`Billetto::SyncEventsService`).
- **Error Handling:** Handled network exceptions and HTTP status codes to ensure reliable API communication.
- **Idempotent Persistence:** Used `find_or_initialize_by(external_id: ...)` to prevent duplicate records during synchronization.

### 3.3 Clerk Authentication

- **Frontend Integration:** Integrated Clerk's frontend SDK for user authentication and management.
- **Backend Verification:** Extracted and verified session JWTs on the server using `ClerkAuthenticatable`.
- **Security:** Ensured that only authenticated users with verified sessions can publish vote events.

## 4. Key Assumptions

### 4.1 Idempotent Ingestion

- The Billetto API's `id` is used as the `external_id`.
- A database unique index on `external_id` prevents duplicate records.
- The synchronization task can be safely re-run without creating duplicate events.

### 4.2 Vote Representation

- Each event's score is calculated as:

  ```ruby
  score = upvotes_count - downvotes_count