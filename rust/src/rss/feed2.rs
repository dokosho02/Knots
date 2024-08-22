use async_sqlite::{JournalMode, PoolBuilder};
use std::error::Error;

pub async fn fetch_feeds_from_db(db_path: &str) -> Result<Vec<(String, String)>, Box<dyn Error>> {
    // 创建数据库连接池
    let pool = PoolBuilder::new()
        .path(db_path)
        .journal_mode(JournalMode::Wal)
        .open()
        .await?;

    // 使用连接池执行查询
    let feeds: Vec<(String, String)> = pool.conn(|conn| {
        conn.prepare("SELECT title, link FROM feeds")?
            .query_map([], |row| {
                Ok((row.get(0)?, row.get(1)?))
            })?
            .collect()
    }).await?;

    println!("rss_sources len: {}", feeds.len());

    // 返回包含所有标题和链接的向量
    Ok(feeds)
}