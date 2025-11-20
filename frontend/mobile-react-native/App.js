import React, { useEffect, useState } from "react";
import { SafeAreaView, Text, TextInput, Button, FlatList, View } from "react-native";

const apiBase = "http://localhost:8000/api/tasks/";

export default function App() {
  const [tasks, setTasks] = useState([]);
  const [title, setTitle] = useState("");

  const load = async () => {
    try {
      const res = await fetch(apiBase);
      const data = await res.json();
      setTasks(data);
    } catch (e) {
      console.log(e);
    }
  };

  useEffect(() => { load(); }, []);

  const add = async () => {
    await fetch(apiBase, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ title })
    });
    setTitle("");
    load();
  };

  return (
    <SafeAreaView style={{ flex: 1, padding: 16 }}>
      <Text style={{ fontSize: 24, fontWeight: "bold" }}>Todo Mobile</Text>
      <TextInput
        placeholder="Title"
        value={title}
        onChangeText={setTitle}
        style={{ borderWidth: 1, marginVertical: 8, padding: 8 }}
      />
      <Button title="Add" onPress={add} />
      <FlatList
        data={tasks}
        keyExtractor={item => String(item.id)}
        renderItem={({ item }) => (
          <View style={{ paddingVertical: 8 }}>
            <Text>{item.title}</Text>
          </View>
        )}
      />
    </SafeAreaView>
  );
}
