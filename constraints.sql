-- 1
ALTER TABLE public.batting ALTER COLUMN ab SET DEFAULT 20;

-- 2
ALTER TABLE public.batting 
        ADD CONSTRAINT batting_constraint CHECK (h > ab);

-- 3
ALTER TABLE public.teams
        ADD CONSTRAINT league_constraint CHECK (lgid IN ('NL','AL'));

-- 4
CREATE OR REPLACE FUNCTION loose()
RETURNS TRIGGER AS $loose$

DECLARE
	team_id varchar(3);
	year_id int4;

  BEGIN

	SELECT teamid, yearid INTO team_id, year_id
		FROM teams
		WHERE l > 161;

  THEN
  
	DELETE *
		FROM batting 
		WHERE teamid = team_id AND yearid = year_id
	RETURN NULL;
END;
$loose$ LANGUAGE plpgsql;



CREATE TRIGGER loose
	AFTER INSERT OR UPDATE ON teams
	FOR EACH ROW
	EXECUTE PROCEDURE loose();
	
	

-- 5

-- procedure checks to see after any record is inserted or deleted
--      to see if any player should be in hall of fame
CREATE OR REPLACE FUNCTION add_if_hall_of_fame( ) 
    RETURNS TRIGGER AS $add_if_hall_of_fame$
DECLARE
        player_id varchar(12);
        season int4;
    BEGIN
        WITH mvp as (
                SELECT masterid, yearid
                FROM awardsplayers
                WHERE awardid = 'Most Valuable Player'
        ),
        wsp as (
                SELECT a.masterid, a.yearid
                FROM awardsplayers a
                JOIN mvp m ON m.masterid = a.masterid AND m.yearid = a.yearid
                WHERE awardid = 'World Series MVP'
        )
        SELECT a.masterid, a.yearid INTO player_id, season
        FROM awardsplayers a
        JOIN wsp w ON w.masterid = a.masterid AND w.yearid = a.yearid
        LEFT JOIN halloffame h ON a.masterid = h.masterid AND a.yearid = h.yearid
        WHERE awardid = 'Gold Glove'
        AND h.masterid IS NULL
        AND h.yearid IS NULL
        ;
        IF player_id IS NOT NULL AND season IS NOT NULL THEN
                INSERT INTO halloffame (masterid, yearid, votedby, category) (SELECT player_id, season, 'db', 'Player');        
        END IF;
        RETURN NULL;
    END;
$add_if_hall_of_fame$ LANGUAGE plpgsql;

-- trigger that calls previous procedure after each isert or update on awardsplayers
CREATE TRIGGER add_if_hall_of_fame_trig AFTER INSERT OR UPDATE
ON awardsplayers
FOR EACH ROW
EXECUTE PROCEDURE add_if_hall_of_fame();

-- 6
ALTER TABLE public.teams
	ADD CONSTRAINT teamNameConstraint CHECK (name != null);

-- 7
ALTER TABLE public.master
	ADD CONSTRAINT nameConstraint UNIQUE (namefirst, namelast); 
