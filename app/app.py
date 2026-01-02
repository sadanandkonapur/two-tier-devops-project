from flask import Flask, render_template, request, jsonify
import sqlite3
import os
from datetime import datetime

app = Flask(__name__)

# Database configuration for SQLite
DB_PATH = os.path.join(os.path.dirname(__file__), 'app.db')

def init_db():
    """Initialize the database with required tables"""
    try:
        conn = sqlite3.connect(DB_PATH)
        c = conn.cursor()
        c.execute('''
            CREATE TABLE IF NOT EXISTS items (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                name TEXT NOT NULL,
                description TEXT,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )
        ''')
        # Insert sample data if table is empty
        c.execute('SELECT COUNT(*) FROM items')
        if c.fetchone()[0] == 0:
            sample_data = [
                ('Sample Item 1', 'This is the first sample item'),
                ('Sample Item 2', 'This is the second sample item'),
                ('Demo Product', 'A demonstration product for testing')
            ]
            c.executemany('INSERT INTO items (name, description) VALUES (?, ?)', sample_data)
        conn.commit()
        conn.close()
        print("Database initialized successfully!")
    except sqlite3.Error as err:
        print(f"Database initialization error: {err}")

def get_db_connection():
    """Create and return a database connection"""
    try:
        connection = sqlite3.connect(DB_PATH)
        connection.row_factory = sqlite3.Row
        return connection
    except sqlite3.Error as err:
        print(f"Error: {err}")
        return None

@app.route('/')
def index():
    """Homepage"""
    return render_template('index.html')

@app.route('/health')
def health():
    """Health check endpoint"""
    return jsonify({'status': 'healthy'}), 200

@app.route('/api/data', methods=['GET'])
def get_data():
    """Retrieve data from database"""
    connection = get_db_connection()
    if connection is None:
        return jsonify({'error': 'Database connection failed'}), 500
    
    try:
        cursor = connection.cursor()
        cursor.execute("SELECT id, name, description, created_at FROM items")
        rows = cursor.fetchall()
        results = [dict(row) for row in rows]
        cursor.close()
        connection.close()
        return jsonify(results), 200
    except sqlite3.Error as err:
        return jsonify({'error': str(err)}), 500

@app.route('/api/data', methods=['POST'])
def add_data():
    """Add data to database"""
    connection = get_db_connection()
    if connection is None:
        return jsonify({'error': 'Database connection failed'}), 500
    
    try:
        data = request.get_json()
        cursor = connection.cursor()
        cursor.execute("INSERT INTO items (name, description) VALUES (?, ?)", 
                      (data.get('name'), data.get('description')))
        connection.commit()
        cursor.close()
        connection.close()
        return jsonify({'message': 'Data added successfully'}), 201
    except sqlite3.Error as err:
        return jsonify({'error': str(err)}), 500

if __name__ == '__main__':
    init_db()
    app.run(host='0.0.0.0', port=5000, debug=True)
