/* Welcome to the SQL mini project. You will carry out this project partly in
the PHPMyAdmin interface, and partly in Jupyter via a Python connection.

This is Tier 2 of the case study, which means that there'll be less guidance for you about how to setup
your local SQLite connection in PART 2 of the case study. This will make the case study more challenging for you: 
you might need to do some digging, and revise the Working with Relational Databases in Python chapter in the previous resource.

Otherwise, the questions in the case study are exactly the same as with Tier 1. 

PART 1: PHPMyAdmin
You will complete questions 1-9 below in the PHPMyAdmin interface. 
Log in by pasting the following URL into your browser, and
using the following Username and Password:

URL: https://sql.springboard.com/
Username: student
Password: learn_sql@springboard

The data you need is in the "country_club" database. This database
contains 3 tables:
    i) the "Bookings" table,
    ii) the "Facilities" table, and
    iii) the "Members" table.

In this case study, you'll be asked a series of questions. You can
solve them using the platform, but for the final deliverable,
paste the code for each solution into this script, and upload it
to your GitHub.

Before starting with the questions, feel free to take your time,
exploring the data, and getting acquainted with the 3 tables. */


/* QUESTIONS 
/* Q1: Some of the facilities charge a fee to members, but some do not.
Write a SQL query to produce a list of the names of the facilities that do. */

ANSWER 1:

SELECT name, membercost
FROM Facilities
WHERE membercost != '0.0'
LIMIT 0 , 1000;


/* Q2: How many facilities do not charge a fee to members? */

ANSWER 2:

SELECT name, membercost
FROM Facilities
WHERE membercost = '0.0'
LIMIT 0 , 1000;


/* Q3: Write an SQL query to show a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost.
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */

ANSWER 3: 

SELECT facid, name, membercost, monthlymaintenance
FROM Facilities
WHERE membercost != 0
AND membercost < monthlymaintenance * 0.2;


/* Q4: Write an SQL query to retrieve the details of facilities with ID 1 and 5.
Try writing the query without using the OR operator. */

ANSWER 4:

SELECT *
FROM Facilities
WHERE facid BETWEEN 1 AND 5;

/* Q5: Produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100. Return the name and monthly maintenance of the facilities
in question. */

ANSWER 5:

SELECT name, monthlymaintenance,
CASE WHEN monthlymaintenance > 100 THEN 'expensive'
ELSE 'cheap'
END AS 
FROM Facilities;

/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Try not to use the LIMIT clause for your solution. */

ANSWER 6: 

SELECT firstname, surname
FROM Members
WHERE joindate = (
    SELECT MAX(joindate)
    FROM Members);
    
/* Q7: Produce a list of all members who have used a tennis court.
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */

ANSWER 7:

SELECT DISTINCT CONCAT ( m.firstname, ' ', m.surname ) AS member_name, f.name AS facility
FROM Bookings AS b
LEFT JOIN Facilities AS f ON b.facid = f.facid
LEFT JOIN Members AS m ON b.memid = m.memid
WHERE f.name LIKE '%ennis%'
ORDER BY member_name;

/* Q8: Produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30. Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */

ANSWER 8:

SELECT DISTINCT CONCAT ( m.firstname, ' ', m.surname ) AS member_name, f.name AS facility,
CASE WHEN b.memid = 0
THEN f.membercost * b.slots
ELSE f.guestcost * b.slots
END AS cost
FROM Bookings AS b
LEFT JOIN Facilities AS f ON b.facid = f.facid
LEFT JOIN Members AS m ON b.memid = m.memid
WHERE b.starttime LIKE '2012-09-14%'
AND 30 <
CASE WHEN b.memid = 0
THEN f.membercost * b.slots
ELSE f.guestcost * b.slots
END 
ORDER BY cost DESC;

/* Q9: This time, produce the same result as in Q8, but using a subquery. */

ANSWER 9:

SELECT *
FROM(SELECT DISTINCT CONCAT (m.firstname, ' ', m.surname) AS member_name, f.name AS facility,
CASE WHEN b.memid = 0
    THEN f.membercost * b.slots
	ELSE f.guestcost * b.slots
	END AS cost
FROM Bookings AS b
INNER JOIN Facilities AS f ON b.facid = f.facid
AND b.starttime LIKE '2012-09-14%'
INNER JOIN Members AS m ON b.memid = m.memid
)sub
WHERE sub.cost >30
ORDER BY sub.cost DESC

/* PART 2: SQLite

Export the country club data from PHPMyAdmin, and connect to a local SQLite instance from Jupyter notebook 
for the following questions.  

QUESTIONS:
/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */

ANSWER 10:

def Q10(conn):
    cur = conn.cursor()
    
    query_Q10 = """
SELECT facility_name, total_revenue
FROM(
    SELECT f.name as facility_name, SUM(b.slots*
    CASE WHEN b.memid = 0 then f.guestcost
    ELSE f.membercost
    END)
        as total_revenue
FROM Facilities as f
INNER JOIN Bookings as b ON f.facid = b.facid
group by f.name)
    as revenues
WHERE total_revenue < 1000
ORDER BY total_revenue
        """
    cur.execute(query_Q10)
    rows = cur.fetchall()
 
    for row in rows:
        print(row)


def main_Q10():
    database = "sqlite_db_pythonsqlite.db" 
    conn = create_connection(database)
    with conn: 
        Q10(conn)
 
if __name__ == '__main__':
    main_Q10()
    
/* Q11: Produce a report of members and who recommended them in alphabetic surname,firstname order */

ANSWER 11:

def Q11(conn):
    cur = conn.cursor()
    
    query_Q11 = """    
SELECT (m.surname || ","|| m.firstname) AS Member, (m2.surname || ","|| m2.firstname) AS Recommender
FROM Members AS m
LEFT JOIN Members AS m2 ON m.recommendedby = m2.memid
WHERE m.recommendedby != 0
ORDER BY Member;
        """
    cur.execute(query_Q11)
    rows = cur.fetchall()
 
    for row in rows:
        print(row)


def main_Q11():
    database = "sqlite_db_pythonsqlite.db" 
    conn = create_connection(database)
    with conn: 
        Q11(conn)
 
if __name__ == '__main__':
    main_Q11()
    

/* Q12: Find the facilities with their usage by member, but not guests */

ANSWER 12:

def Q12(conn):
    cur = conn.cursor()
    
    query_Q12 = """
SELECT f.name AS Facility, (m.firstname || ","|| m.surname) AS Member, COUNT(b.facid) AS Usage
FROM Members AS m
LEFT JOIN Facilities AS f ON f.facid = m.memid
LEFT JOIN Bookings AS b ON b.memid = m.memid
WHERE f.name IS NOT NULL
AND m.surname != 'GUEST'
GROUP BY Member
        """
    cur.execute(query_Q12)
    rows = cur.fetchall()
 
    for row in rows:
        print(row)

def main_Q12():
    database = "sqlite_db_pythonsqlite.db" 
    conn = create_connection(database)
    with conn: 
        Q12(conn)
 
if __name__ == '__main__':
    main_Q12()


/* Q13: Find the facilities usage by month, but not guests */

ANSWER 13: 

def Q13(conn):
    cur = conn.cursor()
    
    query_Q13 = """
SELECT f.name AS Facility, strftime('%m', b.starttime) AS Month, SUM(b.slots) AS Monthly_Usage
FROM Facilities AS f
LEFT JOIN Bookings AS b ON b.facid = f.facid
WHERE b.memid != 0
GROUP BY b.facid, Month
        """
    cur.execute(query_Q13)
    rows = cur.fetchall()
 
    for row in rows:
        print(row)


def main_Q13():
    database = "sqlite_db_pythonsqlite.db" 
    conn = create_connection(database)
    with conn: 
        Q13(conn)
 
if __name__ == '__main__':
    main_Q13()
