# API Documenter

Please help me document all APIs in this codebase systematically:

## 1. API Discovery
Find all API endpoints using these search patterns:

### Express/Node.js
```bash
chs find-code "app\.(get\|post\|put\|delete\|patch)\|router\.(get\|post\|put\|delete\|patch)"
chs find-file "*route*\|*api*\|*controller*"
```

### Decorators (NestJS, TypeScript)
```bash
chs find-code "@(Get\|Post\|Put\|Delete\|Patch)\|@Controller\|@Route"
```

### Other Frameworks
```bash
# Python (FastAPI, Flask, Django)
chs find-code "@app\.(get\|post\|put\|delete)\|@router\|@route"
chs find-code "path\(\|urlpatterns\s*=\|views\."

# Rails/Ruby
chs find-code "resources\s\|get\s['\"]\/\|post\s['\"]\/\|match\s['\"]\/"

# Java/Spring
chs find-code "@(Get\|Post\|Put\|Delete\|Request)Mapping\|@RestController"

# Go
chs find-code "HandleFunc\|Handle\(.*\"\/"
```

## 2. Document Each Endpoint
For every endpoint found, document:

### Endpoint Details
- **Method**: GET, POST, PUT, DELETE, PATCH
- **Path**: Full URL path with parameters
- **Description**: What this endpoint does
- **Authentication**: Required? Type?

### Request
- **Parameters**: Query params, URL params
- **Body**: Expected JSON/form data structure
- **Headers**: Required headers

### Response
- **Success Response**: Status code and body structure
- **Error Responses**: Common error codes and meanings
- **Response Headers**: Any special headers

### Example
```bash
# Generate curl example
curl -X METHOD 'http://localhost:3000/path' \
  -H 'Content-Type: application/json' \
  -d '{"example": "data"}'
```

## 3. Generate Documentation Formats

### README.md Format
Create organized sections by resource:
- User endpoints
- Authentication endpoints
- Product endpoints
- etc.

### OpenAPI/Swagger Format
If applicable, generate OpenAPI spec:
```yaml
paths:
  /users:
    get:
      summary: List users
      responses:
        200:
          description: Success
```

### Postman Collection
Create importable collection with all endpoints

## 4. Validation Checklist
- [ ] All endpoints discovered are documented
- [ ] Authentication requirements clear
- [ ] Request/response examples provided
- [ ] Error cases documented
- [ ] Rate limiting noted
- [ ] CORS settings documented

## 5. Auto-generate Examples
Use actual code to create realistic examples:
- Find test files: `chs find-file "*.test.*" | xargs grep -l "request\|fetch"`
- Extract real API calls from tests
- Use as documentation examples

Create a comprehensive API reference that developers can immediately use!