use std::collections::BTreeMap;
use serde::{Deserialize, Serialize};

#[derive(Serialize, Deserialize, Clone)]
pub struct Podcast {
    id: String,
    author: String,
    name: String,
}

pub fn get_podcasts() -> BTreeMap<&'static str, Podcast> {
    BTreeMap::from([
        ("0", Podcast{ id: "0".to_string(), name: "Never gonna give you up".to_string(), author: "Rick Astley".to_string()}),
        ("1", Podcast{ id: "1".to_string(), name: "Never gonna let you down".to_string(), author: "Rick Astley".to_string()}),
        ("2", Podcast{ id: "2".to_string(), name: "Never gonna run around and desert you".to_string(), author: "Rick Astley".to_string()}),
        ("3", Podcast{ id: "3".to_string(), name: "Never gonna make you cry".to_string(), author: "Rick Astley".to_string()}),
        ("4", Podcast{ id: "4".to_string(), name: "Never gonna say goodbye".to_string(), author: "Rick Astley".to_string()}),
        ("5", Podcast{ id: "5".to_string(), name: "Never gonna tell a lie and hurt you".to_string(), author: "Rick Astley".to_string()}),
        ("6", Podcast{ id: "6".to_string(), name: "Never gonna give you up".to_string(), author: "Rick Astley".to_string()}),
        ("7", Podcast{ id: "7".to_string(), name: "Never gonna let you down".to_string(), author: "Rick Astley".to_string()}),
        ("8", Podcast{ id: "8".to_string(), name: "Never gonna run around and desert you".to_string(), author: "Rick Astley".to_string()}),
        ("9", Podcast{ id: "9".to_string(), name: "Never gonna make you cry".to_string(), author: "Rick Astley".to_string()}),
        ("10", Podcast{ id: "10".to_string(), name: "Never gonna say goodbye".to_string(), author: "Rick Astley".to_string()}),
        ("11", Podcast{ id: "11".to_string(), name: "Never gonna tell a lie and hurt you".to_string(), author: "Rick Astley".to_string()}),
    ])
}

pub fn sample(id: &str) -> std::option::Option<Podcast> {
    get_podcasts()
        .get(id)
        .map(|x| x.clone())
}
