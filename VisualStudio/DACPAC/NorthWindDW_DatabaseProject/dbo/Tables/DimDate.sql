CREATE TABLE [dbo].[DimDate] (
    [DateKey]           INT           NOT NULL,
    [FullDate]          DATE          NOT NULL,
    [DayNumberOfWeek]   INT           NOT NULL,
    [DayNameOfWeek]     NVARCHAR (20) NOT NULL,
    [DayNumberOfMonth]  INT           NOT NULL,
    [DayNumberOfYear]   INT           NOT NULL,
    [WeekNumberOfYear]  INT           NOT NULL,
    [MonthName]         NVARCHAR (20) NOT NULL,
    [MonthNumberOfYear] INT           NOT NULL,
    [CalendarQuarter]   INT           NOT NULL,
    [CalendarYear]      INT           NOT NULL,
    [CalendarSemester]  INT           NOT NULL,
    PRIMARY KEY CLUSTERED ([DateKey] ASC)
);

