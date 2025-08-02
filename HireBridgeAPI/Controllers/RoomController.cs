using HireBridgeAPI.Data;
using HireBridgeAPI.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace HireBridgeAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class RoomController : ControllerBase
    {
        private readonly AppDbContext _context;

        public RoomController(AppDbContext context)
        {
            _context = context;
        }
        [Authorize]
        [HttpPost("add")]
        public IActionResult AddRoom(Room room)
        {
            if (string.IsNullOrEmpty(room.RoomNumber) || room.Capacity <= 0)
            {
                return BadRequest("Invalid room data.");
            }

            try
            {
                _context.Rooms.Add(room);
                _context.SaveChanges();

                return Ok(new
                {
                    message = "Room added successfully",
                    roomId = room.Id,
                    roomNumber = room.RoomNumber,
                    capacity = room.Capacity
                });
            }
            catch (DbUpdateException ex)
            {
                if (ex.InnerException != null && ex.InnerException.Message.Contains("Duplicate entry"))
                {
                    return Conflict($"Room with RoomNumber '{room.RoomNumber}' already exists.");
                }   
                return StatusCode(500, "An error occurred while saving the room.");
            }
            catch (Exception)
            {
                return StatusCode(500, "An unexpected error occurred.");
            }
        }
        [Authorize]
        [HttpGet("all")]
        public IActionResult GetAllRooms()
        {
            var rooms = _context.Rooms
                .Include(r => r.Company)
                .ToList();
            return Ok(rooms);
        }

    }
}
