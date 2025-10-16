use actix_web::{get, web, App, HttpServer, Responder};
use serde::Serialize;

// 1. Define our data structure (the struct)
#[derive(Serialize)]
struct Item {
    id: u32,
    name: String,
}

// 2. Define our request handler function. It's async.
// The #[get("/...")] is a macro that tells Actix to route GET requests here.
#[get("/items/{id}")]
async fn get_item(id: web::Path<u32>) -> impl Responder {
    let requested_id = id.into_inner();

    // In a real app, you would query the database here using the requested_id.
    // For now, we'll just return a dummy item.
    let dummy_item = Item {
        id: requested_id,
        name: format!("Item {}", requested_id),
    };

    // Actix Web automatically converts our struct to a JSON response.
    web::Json(dummy_item)
}

// 3. The main function to configure and start the server.
// The #[actix_web::main] macro sets up the async runtime.
#[actix_web::main]
async fn main() -> std::io::Result<()> {
    println!("🚀 Server starting at http://127.0.0.1:8080");

    HttpServer::new(|| {
        // Register our handler function as a service
        App::new().service(get_item)
    })
    .bind(("127.0.0.1", 8080))?
    .run()
    .await
}
