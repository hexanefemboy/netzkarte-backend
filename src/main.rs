// In src/main.rs
use actix_web::{get, web, App, HttpServer, Responder, Result, error};
use rusqlite::Connection;
use serde::Serialize;

// The Item struct remains the same
#[derive(Serialize)]
struct Item {
    id: i32,
    name: String,
}

// The handler function is now more complex
#[get("/items/{id}")]
async fn get_item(id: web::Path<u32>) -> Result<impl Responder> {
    let item_id = id.into_inner();

    // web::block runs blocking code in a thread pool
    let item = web::block(move || {
        // Open a new connection in the new thread.
        let conn = Connection::open("cell_towers.db")?;

        // Query the database for an item with the given ID.
        conn.query_row(
            "SELECT fid, creation_date FROM towers WHERE fid = ?1",
            [item_id],
            |row| {
                Ok(Item {
                    id: row.get(0)?,
                    name: row.get(1)?,
                })
            },
        )
    })
    .await // Wait for the blocking operation to complete
    .map_err(|e| error::ErrorInternalServerError(e.to_string()))? // Handle thread pool errors
    .map_err(|e| match e {
        // Map rusqlite's "row not found" error to a 404 Not Found response
        rusqlite::Error::QueryReturnedNoRows => error::ErrorNotFound(e.to_string()),
        // Map other database errors to a 500 Internal Server Error
        _ => error::ErrorInternalServerError(e.to_string()),
    })?;

    // If everything is Ok, return the item as JSON
    Ok(web::Json(item))
}

#[actix_web::main]
async fn main() -> std::io::Result<()> {
    println!("🚀 Server starting at http://127.0.0.1:8080");

    HttpServer::new(|| {
        App::new().service(get_item)
    })
    .bind(("127.0.0.1", 8080))?
    .run()
    .await
}
