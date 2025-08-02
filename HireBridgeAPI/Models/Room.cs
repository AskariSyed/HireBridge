namespace HireBridgeAPI.Models;

public class Room
{
    public int Id { get; set; }
    public string RoomNumber { get; set; }
    public int Capacity { get; set; }
    public bool IsOccupied { get; set; } = false;

    public Company? Company { get; set; } 
}
