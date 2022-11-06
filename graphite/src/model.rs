use serde::{Deserialize, Serialize};
use std::collections::BTreeMap;

#[derive(Serialize, Deserialize, Clone)]
pub struct Podcast {
    id: String,
    author: String,
    name: String,
    n_chuncks: u32,
    duration: u32,
}

pub fn get_podcasts() -> BTreeMap<String, Podcast> {
    BTreeMap::from_iter(
        [
            "Never gonna give you up",
            "Never gonna let you down",
            "Never gonna run around and desert you",
            "Never gonna make you cry",
            "Never gonna say goodbye",
            "Never gonna tell a lie and hurt you",
            "Never gonna give you up",
            "Never gonna let you down",
            "Never gonna run around and desert you",
            "Never gonna make you cry",
            "Never gonna say goodbye",
            "Never gonna tell a lie and hurt you",
        ]
        .iter()
        .enumerate()
        .map(|(i, s)| {
            (
                i.to_string(),
                Podcast {
                    id: i.to_string(),
                    author: "Rick Astley".to_string(),
                    name: s.to_string(),
                    n_chuncks: 10,
                    duration: 211,
                },
            )
        }),
    )
}

pub fn sample(id: &str) -> std::option::Option<Podcast> {
    get_podcasts().get(id).map(|x| x.clone())
}
