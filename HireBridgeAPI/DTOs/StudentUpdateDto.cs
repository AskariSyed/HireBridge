namespace HireBridgeAPI.DTOs
{
    public class StudentUpdateDto
    {
        public string? DegreeProgram { get; set; }
        public decimal? GPA { get; set; }
        public string? Skills { get; set; }
        public string? Interests { get; set; }
        public string? FYPTitle { get; set; }
        public string? FYPDescription { get; set; }
        public string? CVPath { get; set; }  // This can be a relative URL or file path
    }
}
