using HireBridgeAPI.Data;
using HireBridgeAPI.DTOs;
using HireBridgeAPI.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

[ApiController]
[Route("api/[controller]")]
public class StudentController : ControllerBase
{
    private readonly AppDbContext _context;

    public StudentController(AppDbContext context)
    {
        _context = context;
    }

    [AllowAnonymous]
    [HttpPost("signup")]
    public async Task<IActionResult> SignUp([FromBody] StudentSignupDto dto)
    {
        if (!ModelState.IsValid)
            return BadRequest(ModelState);

        try
        {
            if (await _context.Users.AnyAsync(u => u.Username == dto.RegistrationNumber))
                return Conflict(new { message = "User with this registration number already exists." });

            var user = new User
            {
                Username = dto.RegistrationNumber,
                PasswordHash = BCrypt.Net.BCrypt.HashPassword(dto.Password),
                Role = "Student",
                FirstTimeLogin = true,
                CreatedAt = System.DateTime.UtcNow
            };

            _context.Users.Add(user);
            await _context.SaveChangesAsync();

            var student = new Student
            {
                UserID = user.UserID,
                Name = dto.Name,
                RegistrationNumber = dto.RegistrationNumber,
                Email = dto.Email,
                CVPath = null,
                DegreeProgram = null,
                GPA = 0,
                Skills = null,
                Interests = null,
                FYPTitle = null,
                FYPDescription = null,
                FCMToken = dto.FCMToken
            };

            _context.Students.Add(student);
            await _context.SaveChangesAsync();

            return Ok(new
            {
                message = "Student registered successfully",
                userId = user.UserID,
                studentId = student.StudentID
            });
        }
        catch (DbUpdateException dbEx)
        {
            var innerMessage = dbEx.InnerException?.Message ?? dbEx.Message;
            return StatusCode(500, new { message = "A database error occurred.", detail = innerMessage });
        }
        catch (Exception ex)
        {
            return StatusCode(500, new { message = "An unexpected error occurred.", detail = ex.Message });
        }
    }

    [AllowAnonymous]
    [HttpPost("login")]
    public async Task<IActionResult> Login([FromBody] StudentLoginDto dto)
    {
        if (!ModelState.IsValid)
            return BadRequest(ModelState);

        try
        {
            var user = await _context.Users.FirstOrDefaultAsync(u => u.Username == dto.RegistrationNumber);
            if (user == null)
                return Unauthorized(new { message = "Invalid registration number or password." });

            bool isPasswordValid = BCrypt.Net.BCrypt.Verify(dto.Password, user.PasswordHash);
            if (!isPasswordValid)
                return Unauthorized(new { message = "Invalid registration number or password." });

            var student = await _context.Students.FirstOrDefaultAsync(s => s.UserID == user.UserID);

           
            if (student != null && !string.IsNullOrEmpty(dto.FCMToken) && student.FCMToken != dto.FCMToken)
            {
                student.FCMToken = dto.FCMToken;
                await _context.SaveChangesAsync();
            }

            return Ok(new
            {
                message = "Login successful",
                userId = user.UserID,
                studentId = student?.StudentID,
                name = student?.Name,
                registrationNumber = user.Username,
                email = student?.Email,
            });
        }
        catch (DbUpdateException dbEx)
        {
            var innerMessage = dbEx.InnerException?.Message ?? dbEx.Message;
            return StatusCode(500, new { message = "A database error occurred.", detail = innerMessage });
        }
        catch (Exception ex)
        {
            Console.WriteLine($"Exception: {ex.Message}");
            Console.WriteLine($"StackTrace: {ex.StackTrace}");

            return StatusCode(500, new { message = "An unexpected error occurred.", detail = ex.ToString() });
        }
    }

    [AllowAnonymous]
    [HttpPost("upload-cv/{studentId}")]
    public async Task<IActionResult> UploadCV(int studentId, IFormFile cvFile)
    {
        if (cvFile == null || cvFile.Length == 0)
            return BadRequest(new { message = "No file uploaded." });

        var student = await _context.Students.FindAsync(studentId);
        if (student == null)
            return NotFound(new { message = "Student not found." });

        try
        {
            var uploadsFolder = Path.Combine(Directory.GetCurrentDirectory(), "wwwroot", "uploads");

            if (!Directory.Exists(uploadsFolder))
                Directory.CreateDirectory(uploadsFolder);

            var uniqueFileName = $"{Guid.NewGuid()}_{cvFile.FileName}";
            var filePath = Path.Combine(uploadsFolder, uniqueFileName);

            using (var stream = new FileStream(filePath, FileMode.Create))
            {
                await cvFile.CopyToAsync(stream);
            }

           
            student.CVPath = Path.Combine("uploads", uniqueFileName).Replace("\\", "/");

            _context.Students.Update(student);
            await _context.SaveChangesAsync();

            return Ok(new { message = "CV uploaded successfully", cvPath = student.CVPath });
        }
        catch (Exception ex)
        {
            return StatusCode(500, new { message = "Error uploading file", detail = ex.Message });
        }
    }
    [AllowAnonymous]
    [HttpPut("update/{studentId}")]
    public async Task<IActionResult> UpdateStudentDetails(int studentId, [FromBody] StudentUpdateDto dto)
    {
        if (!ModelState.IsValid)
            return BadRequest(ModelState);

        var student = await _context.Students.FirstOrDefaultAsync(s => s.StudentID == studentId);
        if (student == null)
            return NotFound(new { message = "Student not found." });
        student.DegreeProgram = dto.DegreeProgram ?? student.DegreeProgram;
        student.GPA = dto.GPA ?? student.GPA;
        student.Skills = dto.Skills ?? student.Skills;
        student.Interests = dto.Interests ?? student.Interests;
        student.FYPTitle = dto.FYPTitle ?? student.FYPTitle;
        student.FYPDescription = dto.FYPDescription ?? student.FYPDescription;
        student.CVPath = dto.CVPath ?? student.CVPath;

        try
        {
            _context.Students.Update(student);
            await _context.SaveChangesAsync();

            return Ok(new { message = "Student details updated successfully." });
        }
        catch (DbUpdateException dbEx)
        {
            var innerMessage = dbEx.InnerException?.Message ?? dbEx.Message;
            return StatusCode(500, new { message = "A database error occurred.", detail = innerMessage });
        }
        catch (Exception ex)
        {
            return StatusCode(500, new { message = "An unexpected error occurred.", detail = ex.Message });
        }
    }

}
