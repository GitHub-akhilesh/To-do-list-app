import os
import psycopg2
from psycopg2.extras import RealDictCursor
import mysql.connector
from mysql.connector import Error

# def get_conn():
#     return psycopg2.connect(
#         dbname=os.environ.get("POSTGRES_DB", "todo_db"),
#         user=os.environ.get("POSTGRES_USER", "todo_user"),
#         password=os.environ.get("POSTGRES_PASSWORD", "todo_pass"),
#         host=os.environ.get("POSTGRES_HOST", "postgres"),
#         port=os.environ.get("POSTGRES_PORT", "5432"),
#     )

def get_conn():
    conn = mysql.connector.connect(
        database=os.environ.get("MYSQL_DB", "todo_db"),
        user=os.environ.get("MYSQL_USER", "root"),
        password=os.environ.get("MYSQL_PASSWORD", "root@123"),
        host=os.environ.get("MYSQL_HOST", "localhost"),
        port=os.environ.get("MYSQL_PORT", "3306")
    )
    return conn

def init_db():
    conn = get_conn()
    cur = conn.cursor()
    cur.execute(
        """
        CREATE TABLE IF NOT EXISTS tasks (
            id SERIAL PRIMARY KEY,
            title VARCHAR(255) NOT NULL,
            description TEXT,
            due_date TIMESTAMP NULL,
            status VARCHAR(32) NOT NULL DEFAULT 'pending',
            created_at TIMESTAMP NOT NULL DEFAULT NOW(),
            updated_at TIMESTAMP NOT NULL DEFAULT NOW()
        );
        """
    )
    conn.commit()
    cur.close()
    conn.close()

def row_to_dict(row):
    return {
        "id": row["id"],
        "title": row["title"],
        "description": row["description"],
        "due_date": row["due_date"].isoformat() if row["due_date"] else None,
        "status": row["status"],
        "created_at": row["created_at"].isoformat() if row["created_at"] else None,
        "updated_at": row["updated_at"].isoformat() if row["updated_at"] else None,
    }

def list_tasks():
    conn = get_conn()
    #cur = conn.cursor(cursor_factory=RealDictCursor)
    cur = conn.cursor(dictionary=True)
    # cur.execute("SELECT * FROM tasks ORDER BY due_date NULLS LAST, created_at DESC")
    cur.execute("""
    SELECT * FROM tasks
    ORDER BY 
        CASE WHEN due_date IS NULL THEN 1 ELSE 0 END,
        due_date ASC,
        created_at DESC
    """)

    rows = cur.fetchall()
    cur.close()
    conn.close()
    return [row_to_dict(r) for r in rows]

def get_task(task_id: int):
    conn = get_conn()
    #cur = conn.cursor(cursor_factory=RealDictCursor)
    cur = conn.cursor(dictionary=True)
    cur.execute("SELECT * FROM tasks WHERE id=%s", (task_id,))
    row = cur.fetchone()
    cur.close()
    conn.close()
    return row_to_dict(row) if row else None

def create_task(data: dict):
    conn = get_conn()
    #cur = conn.cursor(cursor_factory=RealDictCursor)
    cur = conn.cursor(dictionary=True)
    # cur.execute(
    #     """
    #     INSERT INTO tasks (title, description, due_date, status)
    #     VALUES (%s, %s, %s, %s)
    #     RETURNING *;
    #     """,
    #     (
    #         data.get("title"),
    #         data.get("description"),
    #         data.get("due_date"),
    #         data.get("status", "pending"),
    #     ),
    # )
    cur.execute("""
        INSERT INTO tasks (title, description, due_date, status)
        VALUES (%s, %s, %s, %s)
    """, (data.get("title"),data.get("description"),data.get("due_date"),data.get("status", "pending"),))
    row = cur.fetchone()
    conn.commit()
    cur.close()
    conn.close()
    return row_to_dict(row)

def update_task(task_id: int, data: dict):
    conn = get_conn()
    #cur = conn.cursor(cursor_factory=RealDictCursor)
    cur = conn.cursor(dictionary=True)
    # cur.execute(
    #     """
    #     UPDATE tasks SET
    #         title = %s,
    #         description = %s,
    #         due_date = %s,
    #         status = %s,
    #         updated_at = NOW()
    #     WHERE id = %s
    #     RETURNING *;
    #     """,
    #     (
    #         data.get("title"),
    #         data.get("description"),
    #         data.get("due_date"),
    #         data.get("status", "pending"),
    #         task_id,
    #     ),
    # )
    cur.execute("""
        UPDATE tasks
        SET 
            title = %s,
            description = %s,
            due_date = %s,
            status = %s
        WHERE id = %s
    """, (
        data.get("title"),
        data.get("description"),
        data.get("due_date"),
        data.get("status", "pending"),
        task_id,
    ))
    row = cur.fetchone()
    conn.commit()
    cur.close()
    conn.close()
    return row_to_dict(row) if row else None

def delete_task(task_id: int):
    conn = get_conn()
    cur = conn.cursor()
    cur.execute("DELETE FROM tasks WHERE id=%s", (task_id,))
    deleted = cur.rowcount
    conn.commit()
    cur.close()
    conn.close()
    return deleted > 0
