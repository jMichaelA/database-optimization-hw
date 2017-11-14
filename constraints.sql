-- 1

ALTER TABLE public.batting ALTER COLUMN ab SET DEFAULT 20;


-- 3
ALTER TABLE public.teams
        ADD CONSTRAINT league_constraint CHECK (lgid IN ('NL','AL'))

-- 5
