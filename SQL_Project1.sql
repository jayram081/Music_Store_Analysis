/*	Question Set 1 - Easy */

/* Q1: Who is the senior most employee based on job title? */
SELECT first_name||' '||last_name,title,levels FROM employee
ORDER BY levels DESC
LIMIT 1

/* Q2: Which countries have the most Invoices? */
SELECT billing_country,COUNT(invoice_id) AS no_of_invoice FROM invoice
GROUP BY billing_country
ORDER BY no_of_invoice DESC
LIMIT 5

/* Q3: What are top 3 values of total invoice? */
SELECT invoice_id,SUM(total) AS total_invoice FROM invoice
GROUP BY invoice_id
ORDER BY total_invoice DESC
LIMIT 3

/* Q4: Which city has the best customers? We would like to throw a promotional Music Festival in 
the city we made the most money. Write a query that returns one city that has the highest sum of 
invoice totals. Return both the city name & sum of all invoice totals */
SELECT billing_city,SUM(total) AS total_invoice FROM invoice
GROUP BY billing_city
ORDER BY total_invoice DESC
LIMIT 3

/* Q5: Who is the best customer? The customer who has spent the most money will be declared the 
best customer. Write a query that returns the person who has spent the most money.*/
SELECT cx.first_name||' '||cx.last_name, ROUND(SUM(total)::DECIMAL,2) AS total_invoice 
FROM customer cx JOIN invoice i ON cx.customer_id=i.customer_id
GROUP BY cx.first_name||' '||cx.last_name
ORDER BY total_invoice DESC
LIMIT 1

/* Question Set 2 - Moderate */

/* Q1: Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
Return your list ordered alphabetically by email starting with A. */
SELECT DISTINCT cx.first_name||' '||cx.last_name AS full_name,cx.email FROM customer cx
JOIN invoice i ON cx.customer_id=i.customer_id
JOIN invoice_line il ON i.invoice_id=il.invoice_id
JOIN track trk ON il.track_id=trk.track_id
JOIN genre gnr ON trk.genre_id=gnr.genre_id
WHERE gnr.name = 'Rock'
ORDER BY cx.email 

/* 2:Let's invite the artists who have written the most rock music in our dataset. Write a
query that returns the Artist name and total track count of the top 10 rock bands */
SELECT art.name,COUNT(trk.name) track_count FROM artist art 
JOIN album alb ON art.artist_id=alb.artist_id
JOIN track trk ON alb.album_id=trk.album_id
JOIN genre gnr ON gnr.genre_id=trk.genre_id
WHERE gnr.name='Rock'
GROUP BY art.name
ORDER BY track_count DESC
LIMIT 10

/* Return all the track names that have a song length longer than the average song length.
Return the Name and Milliseconds for each track. Order by the song length with the
longest songs listed first */
SELECT name,milliseconds FROM track
WHERE milliseconds > (SELECT AVG(milliseconds) FROM track)
ORDER BY milliseconds DESC

/* Question Set 3 - Advance */

/* Q1: Find how much amount spent by each customer on artists? 
Write a query to return customer name, artist name and total spent */
WITH best_selling_artist AS (
	SELECT artist.artist_id AS artist_id, artist.name AS artist_name, SUM(invoice_line.unit_price*invoice_line.quantity) AS total_sales
	FROM invoice_line
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN album ON album.album_id = track.album_id
	JOIN artist ON artist.artist_id = album.artist_id
	GROUP BY 1
	ORDER BY 3 DESC
	LIMIT 1
)
SELECT c.customer_id, c.first_name, c.last_name, bsa.artist_name, SUM(il.unit_price*il.quantity) AS amount_spent
FROM invoice i
JOIN customer c ON c.customer_id = i.customer_id
JOIN invoice_line il ON il.invoice_id = i.invoice_id
JOIN track t ON t.track_id = il.track_id
JOIN album alb ON alb.album_id = t.album_id
JOIN best_selling_artist bsa ON bsa.artist_id = alb.artist_id
GROUP BY 1,2,3,4
ORDER BY 5 DESC

/* Q2:We want to find out the most popular music Genre for each country. We determine the most popular
genre as the genre with the highest amount of purchases.Write a query that returns each country 
along with the top Genre.For countries where the maximum number of purchases is shared return all Genres. */
WITH popular_genre AS (SELECT billing_country AS country,gnr.name genre,COUNT(il.quantity) AS cnt
FROM invoice i 
JOIN invoice_line il ON i.invoice_id=il.invoice_id
JOIN track trk ON il.track_id=trk.track_id
JOIN genre gnr ON trk.genre_id=gnr.genre_id
GROUP BY 1,2
ORDER BY country  )
SELECT x.country,x.genre,x.cnt FROM
 (SELECT *, DENSE_RANK() OVER(PARTITION BY country ORDER BY cnt DESC) AS rnk FROM popular_genre) x
 WHERE rnk=1

/* Q3: Write a query that determines the customer that has spent the most on music for each country. 
Write a query that returns the country along with the top customer and how much they spent. 
For countries where the top amount spent is shared, provide all customers who spent this amount. */
WITH Customter_with_country AS (
		SELECT customer.customer_id,first_name,last_name,billing_country,SUM(total) AS total_spending,
	    ROW_NUMBER() OVER(PARTITION BY billing_country ORDER BY SUM(total) DESC) AS RowNo 
		FROM invoice
		JOIN customer ON customer.customer_id = invoice.customer_id
		GROUP BY 1,2,3,4
		ORDER BY 4 ASC,5 DESC)
SELECT * FROM Customter_with_country WHERE RowNo <= 1

