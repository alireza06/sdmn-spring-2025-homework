from http.server import BaseHTTPRequestHandler, HTTPServer
import json

PORT = 8000
status_store = {"status": "OK"}  # Shared status storage for API

class MyHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        # Handle GET requests to /api/v1/status
        if self.path == '/api/v1/status':
            self.send_response(200)  # HTTP 200 OK
            self.send_header('Content-Type', 'application/json')
            self.end_headers()
            # Respond with the current status as JSON
            self.wfile.write(json.dumps(status_store).encode('utf-8'))
        else:
            # Respond with 404 if endpoint is not found
            self.send_error(404, "Endpoint not found")

    def do_POST(self):
        # Handle POST requests to /api/v1/status
        if self.path == '/api/v1/status':
            content_length = int(self.headers.get('Content-Length', 0))
            body = self.rfile.read(content_length)
            try:
                data = json.loads(body)  # Parse JSON body
                if 'status' in data:
                    # Update the shared status
                    status_store['status'] = data['status']
                    self.send_response(201)  # HTTP 201 Created
                    self.send_header('Content-Type', 'application/json')
                    self.end_headers()
                    # Respond with the updated status as JSON
                    self.wfile.write(json.dumps(status_store).encode('utf-8'))
                else:
                    # Respond with 400 if 'status' key is missing
                    self.send_error(400, "Missing 'status' in request body")
            except json.JSONDecodeError:
                # Respond with 400 if JSON is invalid
                self.send_error(400, "Invalid JSON format")
        else:
            # Respond with 404 if endpoint is not found
            self.send_error(404, "Endpoint not found")

    def log_message(self, format, *args):
        # Disable default logging to keep output clean
        return

if __name__ == "__main__":
    # Start the HTTP server on the specified port
    with HTTPServer(("", PORT), MyHandler) as httpd:
        print(f"Serving on port {PORT}")
        httpd.serve_forever()