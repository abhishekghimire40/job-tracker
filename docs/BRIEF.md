# Project Brief: Tech Job-Market Tracker

Nov 15, 2026 · @Abhishek Ghimire

## Overview

We need a backend service that collects tech job postings from the monthly Hacker News "Who is hiring?" threads, turns them into structured data, and serves that data to applications and AI assistants.

The posts are free text today, so nobody can search them by skill, filter by salary, or see how demand changes month to month. The system has four parts:

- **A pipeline** that fetches new posts on a schedule and processes them reliably.
- **A database** that keeps the original posts and a clean, structured version of each job.
- **A REST API** that lets developers search jobs and read market statistics.
- **An MCP server** that lets AI assistants answer questions from the same data.

This brief says what the system must do. How it is built is the developer's decision, within the constraints at the end.

## Users and goals

Three kinds of user rely on the system.

| User | What they do | What they need |
| --- | --- | --- |
| API consumer | Calls the REST API from a script or app | Fast, filterable, well-documented endpoints |
| AI assistant user | Asks an assistant questions in plain language | Correct answers drawn from real data |
| Operator | Runs and maintains the system | Visibility into failures, data quality, and cost |

The project succeeds when:

- A new job post is searchable within 2 hours of appearing on Hacker News.
- Extracted fields meet the accuracy targets in the extraction requirements.
- An AI assistant can answer the demo questions in the MCP requirements without help.
- The operator can tell from one dashboard whether the system is healthy and what it costs.

## Scope

The engagement covers the backend only, from fetching posts to serving them.

**In scope**

- Scheduled ingestion of "Who is hiring?" threads, including a 12-month backfill
- Raw and structured storage, monthly aggregates, and data-quality checks
- A versioned REST API with authentication, rate limiting, and caching
- A read-only MCP server exposing the data as tools
- LLM-based field extraction with a rule-based baseline and an evaluation suite
- Tests, CI, containerized deployment to a public URL, metrics, and documentation

**Out of scope**

- Any web or mobile user interface
- Job sources other than Hacker News
- End-user accounts, sign-up flows, or billing
- Applying to jobs or contacting companies
- Training or fine-tuning a model

## Functional requirements

Each requirement has an ID so it can be referenced in commits, tests, and the acceptance review.

### 1. Ingestion

| ID | Requirement |
| --- | --- |
| ING-1 | Fetch every top-level comment from each monthly "Ask HN: Who is hiring?" thread using the official Hacker News API. |
| ING-2 | Run on a schedule with no manual start: at least hourly in the first week of each month and daily afterwards. A manual trigger must also exist. |
| ING-3 | Route fetch work through a message queue. The scheduler and the workers are separate processes, and several workers can run at once. |
| ING-4 | Retry a failed fetch with increasing delays up to a set maximum. After that, park the item where the operator can inspect and replay it. |
| ING-5 | Be idempotent: processing the same thread any number of times produces no duplicate records. |
| ING-6 | Update a post that was edited on the source. Mark a deleted post as deleted instead of removing it. |
| ING-7 | Backfill at least the 12 most recent monthly threads on first run. |
| ING-8 | Limit the request rate to the source so the system is a polite client. |

### 2. Storage and data modeling

| ID | Requirement |
| --- | --- |
| DAT-1 | Store each raw post unmodified, with its source ID, author, timestamps, and thread month. |
| DAT-2 | Store a structured job record per post: company, role title, location, remote policy (remote, hybrid, onsite, unknown), salary minimum, maximum and currency, skills, seniority, visa sponsorship, application link, and a reference to the raw post. |
| DAT-3 | Allow every structured record to be rebuilt from raw data without refetching. Reprocessing everything is a single command. |
| DAT-4 | Normalize skill names so variants count as one skill (for example "golang" and "Go"). |
| DAT-5 | Maintain monthly aggregates: skill counts, remote share, salary range by skill, and posts per company. |
| DAT-6 | Run quality checks after every load: missing company, salary minimum above maximum, implausible salary, duplicate post, empty skill list. Flag failing records, exclude them from the API, and produce a report. |
| DAT-7 | Manage all schema changes through versioned migrations. |

### 3. REST API

| ID | Requirement |
| --- | --- |
| API-1 | List and search jobs with filters for skill, remote policy, location, company, month, minimum salary, and seniority, plus free-text search. |
| API-2 | Return a single job by ID, including its raw text. |
| API-3 | Provide statistics: top skills for a month, the trend of one skill over time, remote share by month, and salary range by skill. |
| API-4 | List companies ranked by number of posts in a period. |
| API-5 | Require an API key on every endpoint except the health check. The operator can issue and revoke keys. |
| API-6 | Paginate every list endpoint with stable ordering. |
| API-7 | Enforce a request limit per key. A blocked request gets a clear response saying when to retry. |
| API-8 | Cache statistics responses and refresh the cache when new data lands. |
| API-9 | Validate all input and return errors in one consistent format. |
| API-10 | Version the API under a `/v1` prefix and publish interactive API documentation. |

### 4. MCP server

| ID | Requirement |
| --- | --- |
| MCP-1 | Expose the data to AI assistants as MCP tools. At minimum: search jobs, get job details, top skills for a month, skill trend over time, and top hiring companies. |
| MCP-2 | Give every tool a clear name, description, and typed parameters, so an assistant picks the right tool without extra instructions. |
| MCP-3 | Keep the server read-only. No tool may change data. |
| MCP-4 | Cap the size of every tool result and say when results were cut off. |
| MCP-5 | Reuse the API's query logic, so the API and the tools never disagree. |
| MCP-6 | Return errors an assistant can act on, such as an unknown skill name with the closest matches. |
| MCP-7 | Work with at least one mainstream MCP-capable assistant. |

Demo questions the assistant must answer correctly through the tools:

- Which companies posted the most Go jobs this month?
- How has demand for Rust changed over the last six months?
- Show me remote senior backend jobs paying over $150k.
- What share of this month's jobs are fully remote, compared with a year ago?

### 5. LLM extraction and evaluation

| ID | Requirement |
| --- | --- |
| LLM-1 | Extract the DAT-2 fields from raw post text using an LLM. Validate the output against a schema, retry once on invalid output, then flag the post. |
| LLM-2 | Provide a rule-based extractor with no LLM for the same fields, as a baseline. |
| LLM-3 | Never guess: a field the post does not state is left empty. |
| LLM-4 | Handle posts that advertise several roles, and document the chosen approach. |
| LLM-5 | Build a golden set of at least 150 real posts labeled by hand, including hard cases, and keep it in version control. |
| LLM-6 | Provide one command that runs any extractor against the golden set and reports accuracy per field, with precision and recall for skills. |
| LLM-7 | Record tokens, cost, and latency per post, and report cost per 1,000 posts. |
| LLM-8 | Meet these targets on the golden set: company 95%, remote policy 90%, salary 85%, skills precision and recall 85% each. |
| LLM-9 | Run the evaluation in CI. The build fails if any field falls more than 2 points below the recorded baseline. |
| LLM-10 | Make the model and prompt configurable without code changes. Each job record stores the extractor version that produced it. |
| LLM-11 | Enforce a monthly spend cap. When it is reached, extraction pauses and everything else keeps running. |
| LLM-12 | Publish a results table comparing the baseline and at least two models on accuracy, cost, and latency. |

## Non-functional requirements

These apply across the whole system and are checked at acceptance.

| Area | Requirement |
| --- | --- |
| Reliability | No post is lost if a worker crashes mid-job. After a restart the system resumes where it stopped, with no manual cleanup. |
| Performance | List and statistics endpoints respond in under 300 ms at the 95th percentile on 12 months of data. A full monthly thread is processed within 30 minutes. |
| Security | No secrets in the repository. API keys are stored hashed. All database queries are safe from injection. CI scans dependencies for known vulnerabilities. |
| Testing | Unit tests cover parsing and business logic. Integration tests run against a real database and queue. Core logic has at least 80% coverage. |
| CI/CD | Every push runs lint, tests, the evaluation, and a container build. The main branch deploys automatically. |
| Observability | Structured logs, plus metrics for posts ingested, queue depth, failed jobs, API latency and error rate, and LLM spend, shown on one dashboard. |
| Deployment | The full system starts locally with one command and runs in containers. A live instance is reachable at a public URL. |
| Cost | The live instance runs on one small cloud server or a free tier. |
| Documentation | A README with setup steps, an architecture diagram, the evaluation results, and a record of key design decisions and their trade-offs. |

## Deliverables and acceptance criteria

The developer hands over five things:

1. A public source repository with full commit history
2. A live deployment with a public URL and a demo API key
3. The MCP server, with instructions for connecting it to an assistant
4. The golden set, the evaluation command, and the published results table
5. The documentation listed under non-functional requirements

The work is accepted when every check below passes in a live review:

- [ ] A fresh clone starts the whole system with one documented command.
- [ ] Running ingestion twice on the same thread leaves the record count unchanged.
- [ ] Killing a worker mid-run loses no posts once it restarts.
- [ ] A deliberately failing fetch is retried, then parked, and can be replayed.
- [ ] A request without a valid API key is rejected.
- [ ] Exceeding the rate limit returns a clear response with a retry time.
- [ ] A filtered, paginated job search returns correct results within the latency target.
- [ ] Records failing a quality check are absent from API results and present in the report.
- [ ] An AI assistant answers all four demo questions through the MCP tools.
- [ ] The evaluation command reproduces the published accuracy, cost, and latency figures.
- [ ] All accuracy targets in LLM-8 are met.
- [ ] Lowering extraction quality on purpose makes the CI build fail.
- [ ] The dashboard shows ingestion, queue, API, and spend metrics from the live instance.
- [ ] CI is green on the main branch.

## Milestones

Delivery is in six phases, each ending in something that runs. Phases 1 to 4 form a complete product with no AI in it.

| Phase | Delivers | Done when | Rough effort |
| --- | --- | --- | --- |
| 1. Foundation | Repository, local environment, database schema, health endpoint, CI running | One command starts the stack and CI passes | 1 week |
| 2. Ingestion | Scheduler, queue, workers, retries, idempotency, backfill (ING-1 to ING-8) | 12 months of raw posts are loaded and a re-run adds nothing | 1 to 2 weeks |
| 3. Data and baseline | Rule-based extractor, structured records, aggregates, quality checks (DAT-1 to DAT-7, LLM-2) | Clean job records and a quality report exist for every month | 1 to 2 weeks |
| 4. API and operations | Full REST API, metrics, dashboard, public deployment (API-1 to API-10) | The live URL serves searches and statistics within the latency target | 2 weeks |
| 5. MCP server | Tools for AI assistants (MCP-1 to MCP-7) | An assistant answers the four demo questions | 1 week |
| 6. LLM extraction and evaluation | Golden set, LLM extractor, evaluation in CI, results table (LLM-1, LLM-3 to LLM-12) | Accuracy targets are met and the results table is published | 2 weeks |

## Where to go deep

The requirements above are enough. Extra time goes into depth on three areas, not into new features.

| Area | Go deep on | Be able to demo |
| --- | --- | --- |
| Ingestion reliability (ING-4, ING-5) | Retries with backoff, idempotent writes, and recovery after a crash | Run the fetcher twice and show the record count unchanged. Kill a worker mid-run and show nothing is lost. |
| The database (DAT-1 to DAT-7) | A schema you can justify, migrations, and indexes chosen from measured query times | Show one slow query's timing before and after adding an index, with the query plan. |
| API production behaviour (API-5 to API-9) | Authentication, pagination, rate limiting, caching, and consistent errors, each with a test | Hit the rate limit live. Show a cached statistics call against an uncached one. |

### What to show reviewers

Most reviewers spend a minute or two on a project, so these must be visible without running anything:

- A live public URL with a demo API key that works
- The interactive API documentation page
- A green CI badge on the README
- A screenshot of the metrics dashboard
- Measured numbers: API response time, posts processed, and after phase 6, extraction accuracy and cost per 1,000 posts
- `DECISIONS.md` with the trade-off behind each main choice

### README order

1. One sentence on what the project is
2. The live URL, the docs link, and the demo API key
3. An architecture diagram
4. The hard problems solved, in three to five bullets
5. The measured numbers
6. How to run it locally with one command
7. Design decisions and known limits

### What weakens the project

- A long feature list where nothing is tested or deployed
- A README that lists technologies without explaining any decision
- Code the developer cannot explain line by line
- AI features with no measurement of whether they work
- Numbers that were estimated instead of measured

## Constraints and developer decisions

The client fixes a few constraints and leaves the technical choices to the developer.

**Constraints**

- Use only the official Hacker News API. No scraping of HTML pages.
- Use open-source or free-tier components, apart from the LLM provider.
- Keep total LLM spend for development and the live instance under a cap the developer sets and documents.
- Store no personal data beyond what is public in the posts.

**Left to the developer, with the reasoning written down**

- Programming language and web framework
- Queue technology
- Database and table design
- Transformation approach for aggregates
- Hosting provider
- LLM provider, models, and prompt design
- Caching strategy and rate-limit values
- Whether a multi-role post becomes one record or several

**Stretch goals, not required for acceptance**

- A second job source feeding the same pipeline
- A natural-language query tool that answers questions not covered by the fixed tools
- Alerts when ingestion stalls or quality checks spike
- Load-test results published alongside the latency figures
