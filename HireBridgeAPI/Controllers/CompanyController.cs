using HireBridgeAPI.Data;
using HireBridgeAPI.DTOs;
using HireBridgeAPI.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;


namespace HireBridgeAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class CompanyController : ControllerBase
    {
        private readonly AppDbContext _context;

        public CompanyController(AppDbContext context)
        {
            _context = context;
        }
        [Authorize]
        [HttpPost("register")]
        public IActionResult RegisterCompany([FromBody] CompanyRegisterDto dto)
        {
            try
            {
                var room = _context.Rooms
                    .Where(r => r.Capacity >= dto.NumReps && !r.IsOccupied)
                    .OrderBy(r => r.Capacity)
                    .FirstOrDefault();

                var company = new Company
                {
                    Name = dto.Name,
                    HRContact = dto.HRContact,
                    Domain = dto.Domain,
                    NumReps = dto.NumReps,
                    Username = dto.Username,
                    PasswordHash = BCrypt.Net.BCrypt.HashPassword(dto.Password),
                    AssignedRoomId = room?.Id,
                    EstimatedInterviewDuration=dto.EstimatedInterviewDuration
                };

                if (room != null)
                {
                    room.IsOccupied = true;
                }

                _context.Companies.Add(company);
                _context.SaveChanges();

                return Ok(new
                {
                    message = "Company registered successfully",
                    username = company.Username,
                    tempPassword = "Password sent to the Email of the representative",
                    room = room?.RoomNumber ?? "Not assigned"
                });
            }
            catch (DbUpdateException dbEx)
            {
                return StatusCode(500, $"Database error: {dbEx.Message}");
            }
            catch (Exception ex)
            {
                return StatusCode(500, $"Unexpected error: {ex.Message}");
            }
        }
        [Authorize]
        [HttpGet("all")]
        public IActionResult GetAllCompaniesWithRooms()
        {
            try
            {
                var companies = _context.Companies
                    .Include(c => c.AssignedRoom)
                    .Select(c => new
                    {
                        CompanyId = c.Id,
                        CompanyName = c.Name,
                        Username = c.Username,
                        HRContact = c.HRContact,
                        Domain = c.Domain,
                        NumReps = c.NumReps,
                        RoomNumber = c.AssignedRoom != null ? c.AssignedRoom.RoomNumber : "Yet to be allotted",
                        EstimatedinterviewDuration=c.EstimatedInterviewDuration
                    })
                    .ToList();

                return Ok(companies);
            }
            catch (Exception ex)
            {
                return StatusCode(500, $"Unexpected error: {ex.Message}");
            }
        }

        [HttpGet("filter")]
        public IActionResult FilterCompaniesByRoomAssignment([FromQuery] bool isAssigned)
        {
            try
            {
                var companiesQuery = _context.Companies
                    .Include(c => c.AssignedRoom)
                    .AsQueryable();

                if (isAssigned)
                {
                    companiesQuery = companiesQuery.Where(c => c.AssignedRoom != null);
                }
                else
                {
                    companiesQuery = companiesQuery.Where(c => c.AssignedRoom == null);
                }

                var companies = companiesQuery
                    .Select(c => new
                    {
                        CompanyId = c.Id,
                        CompanyName = c.Name,
                        HRContact = c.HRContact,
                        Domain = c.Domain,
                        NumReps = c.NumReps,
                        RoomNumber = c.AssignedRoom != null ? c.AssignedRoom.RoomNumber : "Yet to be allotted",
                        EstimatedinterviewDuration = c.EstimatedInterviewDuration  
                    })
                    .ToList();

                return Ok(companies);
            }
            catch (Exception ex)
            {
                return StatusCode(500, $"Unexpected error: {ex.Message}");
            }
        }

    }
}
