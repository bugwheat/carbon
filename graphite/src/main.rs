use actix_web::{get, middleware, web, App, HttpServer};

mod model;

#[get("/podcast/{id}")]
async fn podcast(id: web::Path<String>) -> std::io::Result<String> {
    let podcast = crate::model::sample(&id)
        .ok_or(std::io::Error::new(std::io::ErrorKind::Other, "not found"))?;
    Ok(serde_json::to_string(&podcast)?)
}

#[get("/podcast/{id}/data")]
async fn audio(_: web::Path<String>) -> std::io::Result<actix_files::NamedFile> {
    actix_files::NamedFile::open("data/rickroll.mp3")
}

#[get("/podcasts")]
async fn podcasts() -> std::io::Result<String> {
    Ok(serde_json::to_string(
        &crate::model::get_podcasts()
            .iter()
            .map(|(_, x)| x.clone())
            .collect::<Vec<crate::model::Podcast>>()
    )?)
}

#[actix_web::main]
async fn main() -> std::io::Result<()> {
    std::env::set_var("RUST_LOG", "actix_web=info");
    env_logger::init();

    HttpServer::new(|| {
        App::new()
            .wrap(middleware::Logger::default())
            .service(audio)
            .service(podcast)
            .service(podcasts)
    })
    .bind(("127.0.0.1", 8080))?
    .run()
    .await
}
