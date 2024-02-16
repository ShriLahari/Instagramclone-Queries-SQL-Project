
-- SQL ADV PROJECT - OCT_2023

use ig_clone;

-- Q1 How many times does the average user post?
select round(avg(u_posts)) as avg__posts 
from (select u.id,count(p.id) as u_posts from users u
left join photos p on p.user_id=u.id
group by u.id) as u_p;

-- Q2 Find the top 5 most used hashtags. 

select t.tag_name as TagName,t.id as TagId ,
(select count(*) from photo_tags pt where pt.tag_id = t.id ) as Most_used_Tags  
FROM tags t
group by t.id 
order by Most_used_Tags desc
limit 5;

/* USING JOINS 
select t.tag_name as TagName,t.id as TagId ,count(*) as Most_used_Tags  FROM tags t
inner join photo_tags pt
on pt.tag_id = t.id
group by t.id 
order by Most_used_Tags desc
limit 5; */

-- Q3 Find users who have liked every single photo on the site. 

select distinct(u.id) as user_id, u.username,count(u.id) as likesEveryPhoto from users u
inner join likes l 
on l.user_id=u.id  
group by u.id
having likesEveryPhoto = (select count(*) from photos);  

/*Q4 Retrieve a list of users along with their usernames and the rank of their 
account creation, ordered by the creation date in ascending order.*/

select distinct(u.id) as user_id, u.username, u.created_at,
dense_rank () over(order by created_at asc) as RankOfUsers from users u;  

/* Q5 List the comments made on photos with their comment texts, photo URLs, and usernames of users who posted the comments. 
Include the comment count for each photo*/ 

select c.comment_text, p.image_url, u.username,c.photo_id,
count(c.comment_text) over(partition by c.photo_id order by c.photo_id desc) as count_comment from comments c
inner join users u on u.id=c.user_id 
inner join photos p on p.user_id=c.user_id
group by c.photo_id,c.comment_text,p.image_url,u.username;   
 

/* Q6 For each tag, show the tag name and the number of photos associated with that tag. 
Rank the tags by the number of photos in descending order.*/

select t.id as Tag_ID,t.tag_name as TagName, count(pt.photo_id) as tot_photos,
dense_rank() over(order by count(distinct(pt.photo_id)) desc) as rank_Photos FROM tags t
inner join photo_tags pt
on pt.tag_id = t.id
group by t.id,t.tag_name 
order by tot_photos desc; 

/* Q7 List the usernames of users who have posted photos along with the count of photos they have posted. 
Rank them by the number of photos in descending order.*/  

select u.username, count(distinct(p.id)) as tot_photos,
dense_rank() over(order by count(distinct(p.id)) desc) as Rank_Photos from users u 
inner join photos p on p.user_id=u.id
group by u.username 
order by tot_photos desc;  

/* Q8 Display the username of each user along with the creation date of their first posted photo 
and the creation date of their next posted photo. */

select u.id as UserID,u.username as User_Name , 
first_value(u.created_at) over(partition by u.id order by u.created_at ) as first_posted ,
last_value(u.created_at) over(partition by u.id order by u.created_at ) as next_posted 
from users u
inner join photos p on p.user_id=u.id
group by u.username,u.id
order by u.id ;

/* Q9 For each comment, show the comment text, the username of the commenter, and the 
comment text of the previous comment made on the same photo.*/ 

select u.username,c.photo_id,c.id as Comment_ID,c.comment_text, 
lag(comment_text,1) over(partition by photo_id order by c.photo_id) as previous_comment from users u
inner join comments c on c.user_id=u.id
group by c.id;

/* Q10 A)Show the username of each user along with the number of photos they have posted and 
B)the number of photos posted by the user before them and after them, based on the creation date. */

-- USING 2 VIEWS TO GET THE DESIRED OUTPUT

-- I VIEW
create view vw_photouser as
select u.id as User_ID,u.username as User_Name,p.id as Photo_ID,u.created_at as Creation_Date,
count(p.id) over(partition by u.id order by u.created_at desc) as count_photo from users u 
inner join photos p 
on p.user_id = u.id
group by u.created_at,p.id 
order by u.created_at ; 
 
select * from vw_photouser; 

-- II VIEW
create view vw_CC_P as
select distinct(Creation_Date) as Date_Of_Creation ,User_Name , count_photo as Photo_Cnt from vw_photouser;

select * from vw_CC_P; 

-- FINAL DESIRED RESULTS

select *,
(lead(Photo_Cnt) over(rows between 1 preceding and 1 following)+ 
lag(Photo_Cnt) over(rows between 1 preceding and 1 following)) as Photo_Cnt_Before_After
 from vw_CC_P; 
 
 ---------------------------------------------------------------------------------------------------------- 



    




