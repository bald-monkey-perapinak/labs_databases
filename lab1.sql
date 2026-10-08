CREATE TABLE IF NOT EXISTS accounts (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    email VARCHAR(255) NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    registered_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT uq_accounts_email UNIQUE (email),
    CONSTRAINT chk_accounts_email_format
        CHECK (email ~* '^[^@\s]+@[^@\s]+\.[^@\s]+$')
);

CREATE TABLE IF NOT EXISTS account_profiles (
    account_id BIGINT PRIMARY KEY,
    display_name VARCHAR(100) NOT NULL,
    bio TEXT,
    avatar_url TEXT,
    country CHAR(2),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_account_profiles_account
        FOREIGN KEY (account_id)
        REFERENCES accounts(id)
        ON DELETE CASCADE,

    CONSTRAINT chk_account_profiles_display_name_not_empty
        CHECK (length(trim(display_name)) > 0)
);

CREATE TABLE IF NOT EXISTS channels (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    acc_id BIGINT NOT NULL,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    avatar_url TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_channels_account
        FOREIGN KEY (acc_id)
        REFERENCES accounts(id)
        ON DELETE CASCADE,

    CONSTRAINT chk_channels_name_not_empty
        CHECK (length(trim(name)) > 0)
);

CREATE TABLE IF NOT EXISTS subscriptions (
    subscriber_id BIGINT NOT NULL,
    target_id     BIGINT NOT NULL,
    subscribed_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (subscriber_id, target_id),

    CONSTRAINT fk_subscriptions_subscriber
        FOREIGN KEY (subscriber_id)
        REFERENCES channels(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_subscriptions_target
        FOREIGN KEY (target_id)
        REFERENCES channels(id)
        ON DELETE CASCADE,

    CONSTRAINT chk_subscriptions_not_self
        CHECK (subscriber_id <> target_id)
);

CREATE TABLE IF NOT EXISTS videos (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    channel_id BIGINT NOT NULL,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    url TEXT NOT NULL,
    duration_sec INT NOT NULL,
    published_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_videos_channel
        FOREIGN KEY (channel_id)
        REFERENCES channels(id)
        ON DELETE CASCADE,

    CONSTRAINT chk_videos_duration
        CHECK (duration_sec > 0),

    CONSTRAINT chk_videos_title_not_empty
        CHECK (length(trim(title)) > 0)
);

CREATE TABLE IF NOT EXISTS comments (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    video_id   BIGINT NOT NULL,
    channel_id BIGINT NOT NULL,
    body TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_comments_video
        FOREIGN KEY (video_id)
        REFERENCES videos(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_comments_channel
        FOREIGN KEY (channel_id)
        REFERENCES channels(id)
        ON DELETE CASCADE,

    CONSTRAINT chk_comments_body_not_empty
        CHECK (length(trim(body)) > 0)
);

CREATE TABLE IF NOT EXISTS likes (
    channel_id BIGINT NOT NULL,
    video_id   BIGINT NOT NULL,
    liked_at   TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (channel_id, video_id),

    CONSTRAINT fk_likes_channel
        FOREIGN KEY (channel_id)
        REFERENCES channels(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_likes_video
        FOREIGN KEY (video_id)
        REFERENCES videos(id)
        ON DELETE CASCADE
);
