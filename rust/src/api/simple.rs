use epub::doc::EpubDoc;
use std::io::Cursor;

use crate::rss::feed;
use std::path::Path;

use chrono::{DateTime, Utc};
// use std::num::ParseIntError;

pub async fn get_relative_time(utc_time_str: &str) -> Result<String, String> {
    // 解析 UTC 时间字符串
    let timestamp = match DateTime::parse_from_rfc3339(&format!("{}Z", utc_time_str.replace(" UTC", ""))) {
        Ok(dt) => dt.with_timezone(&Utc),
        Err(_) => return Err("Invalid time format".to_string()),
    };

    // 获取当前时间
    let now = Utc::now();

    // 计算时间差（秒）
    let seconds_difference = (now - timestamp).num_seconds();

    // 定义时间间隔
    let intervals = [
        ("Y", 365 * 24 * 60 * 60),
        ("M", 30 * 24 * 60 * 60),
        ("w", 7 * 24 * 60 * 60),
        ("d", 24 * 60 * 60),
        ("h", 60 * 60),
        ("m", 60),
        ("s", 1),
    ];

    // 计算并返回相对时间
    for &(label, value) in &intervals {
        let amount = seconds_difference / value;
        if amount >= 1 {
            println!("{}{}", amount, label);
            return Ok(format!("{}{}", amount, label));
        }
    }

    Ok("0s".to_string())
}

pub async fn check_if_file_exists(file_path: &str) -> Result<bool, bool> {
    let path = Path::new(file_path);
    if path.exists() {
        Ok(true)
    } else {
        Ok(false)
    }
}

pub async fn fetch_feeds_from_database_async(db_path: &str) -> Result<Vec<(String, String)>, String> {
    let feeds = feed::fetch_feeds_from_db(db_path).await
    .map_err(|e| e.to_string())?;
    Ok(feeds)
}

pub async fn add_feed_to_database_async(db_path: &str, title: &str, link: &str) -> Result<(), String> {
    feed::add_feed_to_db(db_path, title, link).await
    .map_err(|e| e.to_string())?;
    Ok(())
}


pub async fn fetch_items_by_feed_link_async(db_path: &str, feed_link: &str) -> Result<Vec<(String, String, String)>, String> {
    let items = feed::fetch_items_by_feed_link(db_path, feed_link).await
    .map_err(|e| e.to_string())?;
    Ok(items)
}

pub async fn fetch_contents_by_item_link_async(db_path: &str, item_link: &str) -> Result<String, String> {
    let content = feed::fetch_contents_by_item_link(db_path, item_link).await
    .map_err(|e| e.to_string())?;
    Ok(content)
}


pub async fn fetch_current_feed_link_async(db_path: &str) -> Result<String, String> {
    let link = feed::fetch_current_feed_link(db_path).await
    .map_err(|e| e.to_string())?;
    Ok(link)
}

pub async fn update_current_feed_link_async(db_path: &str, link: &str) -> Result<(), String> {
    feed::update_current_feed_link(db_path, link).await
    .map_err(|e| e.to_string())?;
    Ok(())
}

pub async fn fetch_current_item_link_async(db_path: &str) -> Result<String, String> {
    let link = feed::fetch_current_item_link(db_path).await
    .map_err(|e| e.to_string())?;
    Ok(link)
}

pub async fn update_current_item_link_async(db_path: &str, link: &str) -> Result<(), String> {
    feed::update_current_item_link(db_path, link).await
    .map_err(|e| e.to_string())?;
    Ok(())
}

pub async fn fetch_feed_title_async(db_path: &str, link: &str) -> Result<String, String> {
    let title = feed::fetch_feed_title_by_link(db_path, link).await
    .map_err(|e| e.to_string())?;
    Ok(title)
}

pub async fn fetch_item_title_async(db_path: &str, link: &str) -> Result<String, String> {
    let title = feed::fetch_item_title_by_link(db_path, link).await
    .map_err(|e| e.to_string())?;
    Ok(title)
}

pub async fn fetch_published_at_async(db_path: &str, link: &str) -> Result<String, String> {
    let published_at = feed::fetch_published_at_by_link(db_path, link).await
    .map_err(|e| e.to_string())?;
    Ok(published_at)
}

pub async fn fetch_is_starred_by_item_link_async(db_path: &str, link: &str) -> Result<i32, String> {
    let is_starred = feed::fetch_is_read_by_item_link(db_path, link).await
    .map_err(|e| e.to_string())?;
    Ok(is_starred)
}

pub async fn fetch_is_read_by_item_link_async(db_path: &str, link: &str) -> Result<i32, String> {
    let is_read = feed::fetch_is_read_by_item_link(db_path, link).await
    .map_err(|e| e.to_string())?;
    Ok(is_read)
}


pub async fn create_current_settings_db_async(db_path: &str) -> Result<(), String> {
    feed::create_current_settings_db(db_path).await
    .map_err(|e| e.to_string())?;
    Ok(())
}


#[flutter_rust_bridge::frb(opaque)]
pub struct FileProcessor {
    data: Vec<u8>,
    file_type: String, // 可以用来区分不同类型的文件
}



impl FileProcessor {
    pub fn new(file_type: &str) -> Self {
        Self {
            data: Vec::new(),
            file_type: file_type.to_string(),
        }
    }

    pub fn process_chunk(&mut self, chunk: Vec<u8>) -> Result<(), String> {
        self.data.extend_from_slice(&chunk);
        Ok(())
    }

    pub fn finalize(&mut self) -> Result<Vec<String>, String> {
        // 根据 file_type 来处理不同的文件
        match self.file_type.as_str() {
            "epub" => {
                let cursor = Cursor::new(&self.data);
                let doc = EpubDoc::from_reader(cursor).map_err(|e| e.to_string())?;
                
                let title = doc.mdata("title").unwrap_or("Unknown".to_string());
                // Ok(format!("Title: {}\nRead by Rust", title))
                let result = vec![format!("Title: {}\nRead by Rust", title)];
                Ok(result)
            },
            _ => {
                Err("Unsupported file type".to_string())
            }
        }
    }
}

pub fn create_processor(file_type: &str) -> FileProcessor  {
    FileProcessor::new(file_type)
}

// #[flutter_rust_bridge::frb(sync)]
pub fn process_chunk(mut processor: FileProcessor, chunk: Vec<u8>) -> Result<FileProcessor, String> {
    processor.process_chunk(chunk)?;
    Ok(processor)
}

// #[flutter_rust_bridge::frb(sync)]
pub fn finalize_processing(processor:&mut FileProcessor) -> Result<Vec<String>, String> {
    processor.finalize()
}

#[flutter_rust_bridge::frb(sync)] // Synchronous mode for simplicity of the demo
pub fn greet(name: String) -> String {
    format!("Hello, {name}!")
}

#[flutter_rust_bridge::frb(init)]
pub fn init_app() {
    // Default utilities - feel free to customize
    flutter_rust_bridge::setup_default_user_utils();
}
