-- 1
ALTER TABLE public.batting ALTER COLUMN ab SET DEFAULT 20;

-- 2
ALTER TABLE public.batting 
        ADD CONSTRAINT batting_constraint CHECK (h > ab);

-- 3
ALTER TABLE public.teams
        ADD CONSTRAINT league_constraint CHECK (lgid IN ('NL','AL'));

-- 4

-- 5

-- 6

-- 7
ALTER TABLE public.master
	ADD CONSTRAINT nameConstraint UNIQUE (namefirst, namelast); 
