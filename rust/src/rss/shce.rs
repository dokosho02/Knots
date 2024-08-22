use diesel::prelude::*;
use diesel::sqlite::SqliteConnection;
use tokio::task;
use std::error::Error;

pub fn establish_connection(db_path: &str) -> SqliteConnection {
    SqliteConnection::establish(db_path).expect(&format!("Error connecting to {}", db_path))
}

pub async fn fetch_feeds_from_db(db_path: &str) -> Result<Vec<(String, String)>, Box<dyn Error>> {
    let connection = establish_connection(db_path);

    let results = task::spawn_blocking(move || {
        sql_query("SELECT title, link FROM feeds")
            .load::<(String, String)>(&connection)
    })
    .await??;

    println!("rss_sources len: {}", results.len());

    Ok(results)
}

pub async fn fetch_items_by_feed_link(
    db_path: &str,
    feed_link_param: &str,
) -> Result<Vec<(String, String, String)>, Box<dyn Error>> {
    let connection = establish_connection(db_path);

    let results = task::spawn_blocking(move || {
        sql_query("SELECT title, link, published_at FROM items WHERE feed_link = ?")
            .bind::<diesel::sql_types::Text, _>(feed_link_param)
            .load::<(String, String, String)>(&connection)
    })
    .await??;

    println!("items len: {}", results.len());

    Ok(results)
}

pub async fn fetch_contents_by_item_link(
    db_path: &str,
    item_link_param: &str,
) -> Result<String, Box<dyn Error>> {
    let connection = establish_connection(db_path);

    let result = task::spawn_blocking(move || {
        sql_query("SELECT contents FROM items WHERE link = ?")
            .bind::<diesel::sql_types::Text, _>(item_link_param)
            .get_result::<(String,)>(&connection)
    })
    .await??;

    Ok(result.0)
}
