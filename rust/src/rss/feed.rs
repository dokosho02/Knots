// use reqwest::Client;
// use feed_rs::parser::parse;

use sqlx::sqlite::SqlitePool;
use std::error::Error;
use sqlx::Row; // 导入 Row trait 以便使用 get 方法

use std::path::Path;
use std::fs::File;


pub async fn add_feed_to_db(db_path: &str, title: &str, link: &str) -> Result<(), Box<dyn Error>> {
    // 连接到数据库
    let pool = SqlitePool::connect(&format!("sqlite:{}", db_path)).await?;

    // 检查是否已经存在相同的 RSS 源
    let existing_feed = sqlx::query(
        "SELECT title FROM feeds WHERE link = ?"
    )
    .bind(link)
    .fetch_optional(&pool)
    .await?;

    // 如果已经存在相同的 RSS 源，则返回错误
    if existing_feed.is_some() {
        return Err("Feed already exists".into());
    }

    // 插入新的 RSS 源到 feeds 表
    sqlx::query(
        "INSERT INTO feeds (title, link) VALUES (?, ?)"
    )
    .bind(title)
    .bind(link)
    .execute(&pool)
    .await?;

    // 返回 Ok
    Ok(())
}

pub async fn fetch_feeds_from_db(db_path: &str) -> Result<Vec<(String, String)>, Box<dyn Error>> {
    // 连接到数据库
    let path = format!("sqlite://{}", db_path);
    println!("{}", path);  // 使用 {} 格式化并打印 path 变量
    let pool = SqlitePool::connect(&path).await?;

    // 从 feeds 表中获取所有 RSS 源的 title 和 link
    let rss_sources = sqlx::query("SELECT title, link FROM feeds")
        .fetch_all(&pool)
        .await?;

    println!("rss_sources len: {}", rss_sources.len());

    // 使用函数式写法提取 title 和 link 并存储在向量中
    let feeds: Vec<(String, String)> = rss_sources
        .into_iter()
        .map(|feed| {
            let title: String = feed.get("title");
            let link: String = feed.get("link");
            // info!("Feed title: {}, link: {}", title, link);
            (title, link)
        })
        .collect();

    // 返回包含所有标题和链接的向量
    Ok(feeds)
}



pub async fn fetch_items_by_feed_link(db_path: &str, feed_link: &str) -> Result<(Vec<(String, String, String)>), Box<dyn Error>> {
    // 连接到数据库
    let pool = SqlitePool::connect(&format!("sqlite:{}", db_path)).await?;

    // 查询与给定 feed_link 相关的所有条目
    let items = sqlx::query(
        // "SELECT title, link, published_at FROM items WHERE feed_link = ?"
        "SELECT title, link, published_at FROM items WHERE feed_link = ? ORDER BY published_at DESC"
    )
    .bind(feed_link)
    .fetch_all(&pool)
    .await?;

    println!("items len: {}", items.len());

    // 使用函数式写法提取 title, link 和 published_at 并存储在向量中
    let items_vec: Vec<(String, String, String)> = items
        .into_iter()
        .map(|item| {
            let title: String = item.get("title");
            let link: String = item.get("link");
            let published_at: String = item.get("published_at");
            // info!("title: {}, link: {}, published_at: {}", title, link, published_at);
            (title, link, published_at)
        })
        .collect();

    // 返回包含所有条目的向量
    Ok(items_vec)
}

pub async fn fetch_contents_by_item_link(db_path: &str, item_link: &str) -> Result<String, Box<dyn Error>> {
    // 连接到数据库
    let pool = SqlitePool::connect(&format!("sqlite:{}", db_path)).await?;

    // 查询与给定 item_link 相关的内容
    let result = sqlx::query(
        "SELECT contents FROM items WHERE link = ?"
    )
    .bind(item_link)
    .fetch_one(&pool)
    .await?;

    // 从查询结果中获取内容
    let contents: String = result.get("contents");

    // 返回内容
    Ok(contents)
}


pub async fn fetch_current_feed_link(db_path: &str) -> Result<String, Box<dyn Error>> {
    // 连接到数据库
    let pool = SqlitePool::connect(&format!("sqlite:{}", db_path)).await?;

    // 查询与给定 item_link 相关的内容
    let result = sqlx::query(
        "SELECT current_feed_link FROM current_params WHERE current_index = 1"
    )
    .fetch_one(&pool)
    .await?;

    // 从查询结果中获取内容
    let link: String = result.get("current_feed_link");

    println!("current_feed_link get: {}", link);

    // 返回内容
    Ok(link)
}

pub async fn update_current_feed_link(db_path: &str, link: &str) -> Result<(), Box<dyn Error>> {
    // 连接到数据库

    println!("db_path: {}, link: {}", db_path, link);
    
    let pool = SqlitePool::connect(&format!("sqlite:{}", db_path)).await?;

    let current_index = 1;
    // 更新 current_feed_link
    sqlx::query(
        "INSERT OR REPLACE INTO current_params (current_index, current_feed_link, current_item_link) VALUES (?, ?, ?)"
    )
    .bind(current_index)
    .bind(link)
    .bind("https://www.example.com")
    .execute(&pool)
    .await?;


    println!("current_feed_link updated to: {}", link);

    // 返回 Ok
    Ok(())
}

pub async fn fetch_current_item_link(db_path: &str) -> Result<String, Box<dyn Error>> {
    // 连接到数据库
    let pool = SqlitePool::connect(&format!("sqlite:{}", db_path)).await?;

    // 查询与给定 item_link 相关的内容
    let result = sqlx::query(
        "SELECT current_item_link FROM current_params WHERE current_index = 1"
    )
    .fetch_one(&pool)
    .await?;

    // 从查询结果中获取内容
    let link: String = result.get("current_item_link");

    // 返回内容
    Ok(link)
}

pub async fn update_current_item_link(db_path: &str, link: &str) -> Result<(), Box<dyn Error>> {
    // 连接到数据库
    let pool = SqlitePool::connect(&format!("sqlite:{}", db_path)).await?;

    // 查询与给定 item_link 相关的内容
    let result = sqlx::query(
        "SELECT * FROM current_params WHERE current_index = 1"
    )
    .fetch_one(&pool)
    .await?;

    // 从查询结果中获取内容
    // let link: String = result.get("current_item_link");
    let feed_link: String = result.get("current_feed_link");
    let current_index: i32 = result.get("current_index");

    // 更新 current_item_link
    sqlx::query(
        "INSERT OR REPLACE INTO current_params (current_index, current_feed_link, current_item_link) VALUES (?, ?, ?)"
    )
    .bind(current_index)
    .bind(feed_link)
    .bind(link)
    .execute(&pool)
    .await?;

    println!("current_item_link updated to: {}", &link);

    // 返回 Ok
    Ok(())
}

pub async fn fetch_feed_title_by_link(db_path: &str, link: &str) -> Result<String, Box<dyn Error>> {
    // 连接到数据库
    let pool = SqlitePool::connect(&format!("sqlite:{}", db_path)).await?;

    // 查询与给定 item_link 相关的内容
    let result = sqlx::query(
        "SELECT title FROM feeds WHERE link = ?"
    )
    .bind(link)
    .fetch_one(&pool)
    .await?;

    // 从查询结果中获取内容
    let title: String = result.get("title");

    // 返回内容
    Ok(title)
}

pub async fn fetch_item_title_by_link(db_path: &str, link: &str) -> Result<String, Box<dyn Error>> {
    // 连接到数据库
    let pool = SqlitePool::connect(&format!("sqlite:{}", db_path)).await?;

    // 查询与给定 item_link 相关的内容
    let result = sqlx::query(
        "SELECT title FROM items WHERE link = ?"
    )
    .bind(link)
    .fetch_one(&pool)
    .await?;

    // 从查询结果中获取内容
    let title: String = result.get("title");

    // 返回内容
    Ok(title)
}

pub async fn fetch_published_at_by_link(db_path: &str, link: &str) -> Result<String, Box<dyn Error>> {
    // 连接到数据库
    let pool = SqlitePool::connect(&format!("sqlite:{}", db_path)).await?;

    // 查询与给定 item_link 相关的内容
    let result = sqlx::query(
        "SELECT published_at FROM items WHERE link = ?"
    )
    .bind(link)
    .fetch_one(&pool)
    .await?;

    // 从查询结果中获取内容
    let published_at: String = result.get("published_at");

    // 返回内容
    Ok(published_at)
}


pub async fn fetch_is_starred_by_item_link(db_path: &str, link: &str) -> Result<i32, Box<dyn Error>> {
    // 连接到数据库
    let pool = SqlitePool::connect(&format!("sqlite:{}", db_path)).await?;

    // 查询与给定 item_link 相关的内容
    let result = sqlx::query(
        "SELECT isStarred FROM items WHERE link = ?"
    )
    .bind(link)
    .fetch_one(&pool)
    .await?;

    // 从查询结果中获取内容
    let res: i32 = result.get("isStarred");

    // 返回内容
    Ok(res)
}


pub async fn fetch_is_read_by_item_link(db_path: &str, link: &str) -> Result<i32, Box<dyn Error>> {
    // 连接到数据库
    let pool = SqlitePool::connect(&format!("sqlite:{}", db_path)).await?;

    // 查询与给定 item_link 相关的内容
    let result = sqlx::query(
        "SELECT isRead FROM items WHERE link = ?"
    )
    .bind(link)
    .fetch_one(&pool)
    .await?;

    // 从查询结果中获取内容
    let res: i32 = result.get("isRead");

    // 返回内容
    Ok(res)
}



pub async fn create_current_settings_db(db_path: &str) -> Result<(), Box<dyn Error>> {

    println!("create db_path: {}", db_path);

    // check if the database file exists, if not, create it
    let path = Path::new(db_path);
    if !path.exists() {
        File::create(&path).expect("Failed to create database file");
        println!("Database file created: {}", db_path);
    } else {
        println!("Database file already exists: {}", db_path);
    }


    // let path = Path::new(db_path);
    // if !path.exists() {
    //     File::create(&path).expect("Failed to create database file");
    //     println!("Database file created: {}", db_path);
    // } else {
    //     println!("Database file already exists: {}", db_path);
    // }

    // 连接到数据库
    let pool = SqlitePool::connect(&format!("sqlite:{}", db_path)).await?;

    // 创建 current_params 表
    sqlx::query(
        "CREATE TABLE IF NOT EXISTS current_params (
            current_index INTEGER PRIMARY KEY,
            current_feed_link TEXT,
            current_item_link TEXT
        )"
    )
    .execute(&pool)
    .await?;



    // 返回 Ok
    Ok(())
}


// async fn fetch_items_by_feed_link(db_path: &str, feed_link: &str) -> Result<(), Box<dyn Error>> {

//     println!("db_path: {}, feed_link: {}", db_path, feed_link);
//     // 连接到数据库
//     let pool = SqlitePool::connect(&format!("sqlite:{}", db_path)).await?;

//     // 查询与给定 feed_link 相关的所有条目
//     let items = sqlx::query(
//         "SELECT title, link, published_at FROM items WHERE feed_link = ?"
//     )
//     .bind(feed_link)
//     .fetch_all(&pool)
//     .await?;

//     println!("items len: {}", items.len());

//     // 输出每个条目的 title, link 和 published_at
//     for item in items {
//         let title: String = item.get("title");
//         let link: String = item.get("link");
//         let published_at: String = item.get("published_at");

//         println!("title: {}\nlink: {}\npublished_at: {}", title, link, published_at);
//     }

//     Ok(())
// }

// async fn fetch_contents_by_item_link(db_path: &str, item_link: &str) -> Result<String, Box<dyn Error>> {
//     // 打印数据库路径和 item_link
//     println!("db_path: {}, item_link: {}", db_path, item_link);

//     // 连接到数据库
//     let pool = SqlitePool::connect(&format!("sqlite:{}", db_path)).await?;

//     // 查询与给定 item_link 相关的内容
//     let result = sqlx::query(
//         "SELECT contents FROM items WHERE link = ?"
//     )
//     .bind(item_link)
//     .fetch_one(&pool)
//     .await?;

//     // 从查询结果中获取内容
//     let contents: String = result.get("contents");

//     println!("Item contents: {}", contents);

//     // 返回内容
//     Ok(contents)
// }