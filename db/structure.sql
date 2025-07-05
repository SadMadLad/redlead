SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: vector; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS vector WITH SCHEMA public;


--
-- Name: EXTENSION vector; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION vector IS 'vector data type and ivfflat and hnsw access methods';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: businesses; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.businesses (
    id bigint NOT NULL,
    business_type character varying,
    title character varying NOT NULL,
    website_url character varying,
    description text NOT NULL,
    intelligent_scraped_summary text,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: businesses_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.businesses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: businesses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.businesses_id_seq OWNED BY public.businesses.id;


--
-- Name: embeddings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.embeddings (
    id bigint NOT NULL,
    embeddable_type character varying NOT NULL,
    embeddable_id bigint NOT NULL,
    embedding_model character varying NOT NULL,
    embedding public.vector NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: embeddings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.embeddings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: embeddings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.embeddings_id_seq OWNED BY public.embeddings.id;


--
-- Name: products; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.products (
    id bigint NOT NULL,
    business_id bigint NOT NULL,
    title character varying,
    description text,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: products_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.products_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: products_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.products_id_seq OWNED BY public.products.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


--
-- Name: solid_cable_messages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.solid_cable_messages (
    id bigint NOT NULL,
    channel bytea NOT NULL,
    payload bytea NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    channel_hash bigint NOT NULL
);


--
-- Name: solid_cable_messages_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.solid_cable_messages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: solid_cable_messages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.solid_cable_messages_id_seq OWNED BY public.solid_cable_messages.id;


--
-- Name: subreddit_post_comments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.subreddit_post_comments (
    id bigint NOT NULL,
    subreddit_post_id bigint,
    parent_id bigint,
    depth integer,
    downs integer,
    likes integer,
    score integer,
    ups integer,
    created_utc bigint,
    author character varying,
    author_fullname character varying,
    display_id character varying,
    link_id character varying,
    name character varying,
    parent_display_id character varying,
    subreddit_name character varying,
    subreddit_str_id character varying,
    subreddit_name_prefixed character varying,
    body text,
    body_html text,
    permalink text,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: subreddit_post_comments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.subreddit_post_comments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: subreddit_post_comments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.subreddit_post_comments_id_seq OWNED BY public.subreddit_post_comments.id;


--
-- Name: subreddit_posts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.subreddit_posts (
    id bigint NOT NULL,
    subreddit_id bigint,
    num_comments integer,
    score integer,
    ups integer,
    upvote_ratio double precision,
    author character varying,
    author_fullname character varying,
    display_id character varying,
    domain character varying,
    name character varying,
    permalink character varying,
    url character varying,
    subreddit_name character varying,
    subreddit_name_prefixed character varying,
    subreddit_str_id character varying,
    selftext text,
    selftext_html text,
    title text,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    created_utc bigint
);


--
-- Name: subreddit_posts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.subreddit_posts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: subreddit_posts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.subreddit_posts_id_seq OWNED BY public.subreddit_posts.id;


--
-- Name: subreddits; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.subreddits (
    id bigint NOT NULL,
    subscribers integer,
    display_name character varying,
    display_id character varying,
    name character varying,
    title character varying,
    url character varying NOT NULL,
    description text,
    description_html text,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    created_utc bigint,
    scraped_at timestamp(6) without time zone
);


--
-- Name: subreddits_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.subreddits_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: subreddits_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.subreddits_id_seq OWNED BY public.subreddits.id;


--
-- Name: businesses id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.businesses ALTER COLUMN id SET DEFAULT nextval('public.businesses_id_seq'::regclass);


--
-- Name: embeddings id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.embeddings ALTER COLUMN id SET DEFAULT nextval('public.embeddings_id_seq'::regclass);


--
-- Name: products id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.products ALTER COLUMN id SET DEFAULT nextval('public.products_id_seq'::regclass);


--
-- Name: solid_cable_messages id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.solid_cable_messages ALTER COLUMN id SET DEFAULT nextval('public.solid_cable_messages_id_seq'::regclass);


--
-- Name: subreddit_post_comments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subreddit_post_comments ALTER COLUMN id SET DEFAULT nextval('public.subreddit_post_comments_id_seq'::regclass);


--
-- Name: subreddit_posts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subreddit_posts ALTER COLUMN id SET DEFAULT nextval('public.subreddit_posts_id_seq'::regclass);


--
-- Name: subreddits id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subreddits ALTER COLUMN id SET DEFAULT nextval('public.subreddits_id_seq'::regclass);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: businesses businesses_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.businesses
    ADD CONSTRAINT businesses_pkey PRIMARY KEY (id);


--
-- Name: embeddings embeddings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.embeddings
    ADD CONSTRAINT embeddings_pkey PRIMARY KEY (id);


--
-- Name: products products_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: solid_cable_messages solid_cable_messages_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.solid_cable_messages
    ADD CONSTRAINT solid_cable_messages_pkey PRIMARY KEY (id);


--
-- Name: subreddit_post_comments subreddit_post_comments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subreddit_post_comments
    ADD CONSTRAINT subreddit_post_comments_pkey PRIMARY KEY (id);


--
-- Name: subreddit_posts subreddit_posts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subreddit_posts
    ADD CONSTRAINT subreddit_posts_pkey PRIMARY KEY (id);


--
-- Name: subreddits subreddits_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subreddits
    ADD CONSTRAINT subreddits_pkey PRIMARY KEY (id);


--
-- Name: index_embeddings_on_embeddable; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_embeddings_on_embeddable ON public.embeddings USING btree (embeddable_type, embeddable_id);


--
-- Name: index_products_on_business_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_products_on_business_id ON public.products USING btree (business_id);


--
-- Name: index_solid_cable_messages_on_channel; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_solid_cable_messages_on_channel ON public.solid_cable_messages USING btree (channel);


--
-- Name: index_solid_cable_messages_on_channel_hash; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_solid_cable_messages_on_channel_hash ON public.solid_cable_messages USING btree (channel_hash);


--
-- Name: index_solid_cable_messages_on_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_solid_cable_messages_on_created_at ON public.solid_cable_messages USING btree (created_at);


--
-- Name: index_subreddit_post_comments_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_subreddit_post_comments_on_name ON public.subreddit_post_comments USING btree (name);


--
-- Name: index_subreddit_post_comments_on_parent_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_subreddit_post_comments_on_parent_id ON public.subreddit_post_comments USING btree (parent_id);


--
-- Name: index_subreddit_post_comments_on_subreddit_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_subreddit_post_comments_on_subreddit_post_id ON public.subreddit_post_comments USING btree (subreddit_post_id);


--
-- Name: index_subreddit_posts_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_subreddit_posts_on_name ON public.subreddit_posts USING btree (name);


--
-- Name: index_subreddit_posts_on_subreddit_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_subreddit_posts_on_subreddit_id ON public.subreddit_posts USING btree (subreddit_id);


--
-- Name: index_subreddits_on_url; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_subreddits_on_url ON public.subreddits USING btree (url);


--
-- Name: subreddit_posts fk_rails_27b507b89b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subreddit_posts
    ADD CONSTRAINT fk_rails_27b507b89b FOREIGN KEY (subreddit_id) REFERENCES public.subreddits(id);


--
-- Name: products fk_rails_64b1679e02; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT fk_rails_64b1679e02 FOREIGN KEY (business_id) REFERENCES public.businesses(id);


--
-- Name: subreddit_post_comments fk_rails_cdbca78470; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subreddit_post_comments
    ADD CONSTRAINT fk_rails_cdbca78470 FOREIGN KEY (parent_id) REFERENCES public.subreddit_post_comments(id);


--
-- Name: subreddit_post_comments fk_rails_f26ed5ff9a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subreddit_post_comments
    ADD CONSTRAINT fk_rails_f26ed5ff9a FOREIGN KEY (subreddit_post_id) REFERENCES public.subreddit_posts(id);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO "schema_migrations" (version) VALUES
('20250628214139'),
('20250626011104'),
('20250625165109'),
('20250625140953'),
('20250621205800'),
('20250619195017'),
('20250618230807'),
('20250614013458'),
('20250614002555'),
('20250614002554');

