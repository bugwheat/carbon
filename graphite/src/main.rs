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

#[get("/podcast/{id}/bin/{chunk}")]
async fn audio_bin(path: web::Path<(String, u32)>) -> std::io::Result<actix_files::NamedFile> {
    let (_, chunk) = *path;
    actix_files::NamedFile::open(format!("data/rickroll-{chunk:03}.bin"))
}

#[get("/podcast/{id}/bin-gz/{chunk}")]
async fn audio_bin_gz(path: web::Path<(String, u32)>) -> std::io::Result<actix_files::NamedFile> {
    let (_, chunk) = *path;
    actix_files::NamedFile::open(format!("data/rickroll-{chunk:03}.bin.gz"))
}

#[get("/podcast/{id}/compressed/{chunk}")]
async fn audio_compressed(path: web::Path<(String, u32)>) -> std::io::Result<actix_files::NamedFile> {
    let (_, chunk) = *path;
    actix_files::NamedFile::open(format!("data/rickroll-{chunk:03}.ecdc"))
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
            .service(audio_bin)
            .service(audio_bin_gz)
            .service(audio_compressed)
            .service(podcast)
            .service(podcasts)
    })
    .bind(("127.0.0.1", 8080))?
    .run()
    .await
}
