BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "chat_message" (
    "id" bigserial PRIMARY KEY,
    "content" text NOT NULL,
    "isUser" boolean NOT NULL,
    "timestamp" timestamp without time zone NOT NULL,
    "chatSessionId" bigint NOT NULL,
    "metadata" text
);

--
-- ACTION CREATE TABLE
--
CREATE TABLE "chat_session" (
    "id" bigserial PRIMARY KEY,
    "title" text NOT NULL,
    "createdAt" timestamp without time zone NOT NULL,
    "userId" bigint
);

--
-- ACTION CREATE TABLE
--
CREATE TABLE "task" (
    "id" bigserial PRIMARY KEY,
    "title" text NOT NULL,
    "description" text,
    "priority" text NOT NULL,
    "dueAt" timestamp without time zone,
    "completed" boolean NOT NULL,
    "createdAt" timestamp without time zone NOT NULL
);


--
-- MIGRATION VERSION FOR butlrapp
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('butlrapp', '20260127233645091', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260127233645091', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod', '20251208110333922-v3-0-0', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20251208110333922-v3-0-0', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod_auth_idp
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_auth_idp', '20260109031533194', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260109031533194', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod_auth_core
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_auth_core', '20251208110412389-v3-0-0', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20251208110412389-v3-0-0', "timestamp" = now();


COMMIT;
