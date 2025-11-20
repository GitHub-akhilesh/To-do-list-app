import React from "react";
import { createRoot } from "react-dom/client";
import axios from "axios";

const apiBase = "/api/tasks/";

function App() {
  const [tasks, setTasks] = React.useState([]);
  const [form, setForm] = React.useState({ title: "", description: "", due_date: "", status: "pending" });

  const load = async () => {
    const res = await axios.get(apiBase);
    setTasks(res.data);
  };

  React.useEffect(() => { load(); }, []);

  const submit = async (e) => {
    e.preventDefault();
    await axios.post(apiBase, form);
    setForm({ title: "", description: "", due_date: "", status: "pending" });
    load();
  };

  const remove = async (id) => {
    await axios.delete(apiBase + id + "/");
    load();
  };

  return (
    <div style={{ maxWidth: 900, margin: "2rem auto", fontFamily: "system-ui" }}>
      <h1>Todo List (React)</h1>
      <form onSubmit={submit} style={{ display: "grid", gap: "0.5rem" }}>
        <input placeholder="Title" value={form.title} onChange={e => setForm({ ...form, title: e.target.value })} />
        <textarea placeholder="Description" value={form.description} onChange={e => setForm({ ...form, description: e.target.value })} />
        <input type="datetime-local" value={form.due_date} onChange={e => setForm({ ...form, due_date: e.target.value })} />
        <select value={form.status} onChange={e => setForm({ ...form, status: e.target.value })}>
          <option value="pending">Pending</option>
          <option value="done">Done</option>
        </select>
        <button type="submit">Add Task</button>
      </form>
      <ul>
        {tasks.map(t => (
          <li key={t.id}>
            <strong>{t.title}</strong> ({t.status}) - {t.due_date}
            <button onClick={() => remove(t.id)}>X</button>
          </li>
        ))}
      </ul>
    </div>
  );
}

const root = createRoot(document.getElementById("root"));
root.render(<App />);
